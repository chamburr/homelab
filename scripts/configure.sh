#!/bin/sh

prepare() {
  export USERNAME="${PWD##*/}"
  export TALOSCONFIG="/home/$USERNAME/.talos/config"
  export KUBECONFIG="/home/$USERNAME/.kube/config"
}

configureTalos() {
  echo 'Configuring talos...'

  mkdir -p .talos .kube
  cd .talos

  curl -sO https://raw.githubusercontent.com/chamburr/homelab/master/scripts/talos/machines.yaml
  curl -sO https://raw.githubusercontent.com/chamburr/homelab/master/scripts/talos/patch.yaml

  talosctl gen config cluster https://192.168.123.10:6443 \
    --config-patch-control-plane @patch.yaml --with-docs=false --with-examples=false

  nodes=$(cat machines.yaml | sed -e '1d' -e 's/- /{"/' -e 's/: /":"/' \
    | sed -z -e 's/\n  /","/g' -e 's/\n/"}\n/g')
  endpoints=$(cat machines.yaml | grep -oE '192.168.{1,4}.{1,4}' | xargs)

  for node in $nodes; do
    name=$(echo $node | jq -r '.name')
    endpoint=$(echo $node | jq -r '.endpoint')

    filename="$name.yaml"
    ip=$(virsh domifaddr $name | grep -oE '192.168.{1,4}.[0-9]{1,4}')

    cp controlplane.yaml $filename
    sed -i -e "s/\$ENDPOINT/$endpoint/g" -e "s/\$HOSTNAME/$name/g" $filename

    talosctl apply-config -i -n $ip -f $filename

    rm $filename
  done

  mv talosconfig config

  talosctl config endpoint $endpoints
  talosctl config node $endpoints

  until talosctl version > /dev/null 2>&1; do
    sleep 5
  done

  talosctl bootstrap -n $(echo $endpoints | cut -f 1 -d ' ')
  talosctl kubeconfig ../.kube/config -n $(echo $endpoints | cut -f 1 -d ' ')

  rm controlplane.yaml worker.yaml
  rm machines.yaml patch.yaml

  cd ..
  chown -R "$USERNAME:$USERNAME" .talos .kube
}

configureFlux() {
  echo 'Configuring flux...'

  until talosctl health -n 192.168.123.10 --wait-timeout 30s > /dev/null 2>&1; do
    sleep 5
  done

  kubectl apply -k 'github.com/fluxcd/flux2/manifests/install?ref=v0.33.0'

  kubectl -n flux-system create secret generic global-vault-secret
  kubectl -n flux-system create secret generic global-secret $(echo $CONFIGURE_VARS \
    | sed -E 's/(\S+)=/\U\1=/g' | xargs -d ' ' -n1 printf ' --from-literal=%s')

  kubectl apply -k 'github.com/chamburr/homelab/kubernetes/base/flux-system?ref=master'

  until flux check --timeout 30s > /dev/null 2>&1; do
    sleep 5
  done

  flux reconcile -n flux-system source git flux-cluster
  flux reconcile -n flux-system kustomization flux-cluster

  flux reconcile kustomization charts
  flux reconcile kustomization crds
  flux reconcile kustomization config
  flux reconcile kustomization core
  flux suspend kustomization apps
}

configureVault() {
  echo 'Configuring vault...'

  until kubectl -n vault wait --for condition=Initialized pod/vault-0 > /dev/null 2>&1; do
    sleep 5
  done

  vault_init=$(kubectl -n vault exec vault-0 -- vault operator init -n 1 -t 1 -format json)
  unseal_key=$(echo $vault_init | jq -r '.unseal_keys_b64[0]')
  root_token=$(echo $vault_init | jq -r '.root_token')

  echo "Vault unseal key is $unseal_key"
  echo "Vault root token is $root_token"

  kubectl -n flux-system delete secret global-vault-secret
  kubectl -n flux-system create secret generic global-vault-secret \
    --from-literal "VAULT_KEY=$unseal_key" --from-literal "VAULT_TOKEN=$root_token"

  kubectl -n vault exec vault-0 -- vault operator unseal "$unseal_key"

  kubectl -n vault exec vault-0 -- vault login -no-print "$root_token"
  kubectl -n vault exec vault-0 -- vault secrets enable -path=secret -version=2 kv
  kubectl -n vault exec vault-0 -- vault auth enable kubernetes

  kubectl -n vault exec vault-0 -- sh -c \
    'echo -e "path \"secret/data/*\" {\n  capabilities = [\"read\"]\n}" \
      | vault policy write vault-secrets-operator -'
  kubectl -n vault exec vault-0 -- sh -c \
    'vault write auth/kubernetes/config \
      issuer="https://kubernetes.default.svc.cluster.local" \
      token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
      kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443 \
      kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt'
  kubectl -n vault exec vault-0 -- sh -c \
    'vault write auth/kubernetes/role/vault-secrets-operator \
      bound_service_account_names=vault-secrets-operator \
      bound_service_account_namespaces=vault \
      policies=vault-secrets-operator \
      ttl=24h'

  kubectl -n vault exec vault-0 -- sh -c \
    "vault kv put secret/flux-system/global $CONFIGURE_VARS"
  kubectl -n vault exec vault-0 -- sh -c \
    "$(curl -s https://raw.githubusercontent.com/chamburr/homelab/master/scripts/vault/secrets.txt)"

  kubectl -n vault exec vault-0 -- rm /home/vault/.vault-token

  flux -n vault reconcile helmrelease vault-secrets-operator
  flux resume kustomization apps
}

prepare
configureTalos
configureFlux
configureVault
