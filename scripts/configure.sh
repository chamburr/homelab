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

  curl -sO https://raw.githubusercontent.com/chamburr/homelab/main/scripts/talos/machines.yaml
  curl -sO https://raw.githubusercontent.com/chamburr/homelab/main/scripts/talos/patch.yaml

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

  sleep 10

  talosctl bootstrap -n $(echo $endpoints | cut -f 1 -d ' ')
  talosctl kubeconfig ../.kube/config -n $(echo $endpoints | cut -f 1 -d ' ')

  rm controlplane.yaml worker.yaml
  rm machines.yaml patch.yaml

  cd ..
  chown -R "$USERNAME:$USERNAME" .talos .kube
}

configureFlux() {
  echo 'Configuring flux...'

  helm repo add cilium https://helm.cilium.io/
  helm repo update

  until helm install cilium cilium/cilium -n cilium --create-namespace --set ipam.mode=kubernetes \
    > /dev/null 2>&1
  do
    sleep 5
  done

  until talosctl health -n 192.168.123.10 --wait-timeout 30s > /dev/null 2>&1; do
    sleep 5
  done

  version=$(curl -s https://api.github.com/repos/fluxcd/flux2/releases/latest | jq -r '.tag_name')

  kubectl apply -k 'github.com/fluxcd/flux2/manifests/install?ref=$version'

  kubectl -n flux-system create secret generic global-secret $(echo $CONFIGURE_VARS \
    | sed -E 's/(\S+)=/\U\1=/g' | xargs -d ' ' -n1 printf ' --from-literal=%s')

  kubectl apply -k 'github.com/chamburr/homelab/kubernetes/base/flux-system?ref=main'

  until flux check --timeout 30s > /dev/null 2>&1; do
    sleep 5
  done

  kubectl -n flux-system delete NetworkPolicy --all

  flux -n flux-system reconcile source git flux-cluster
  flux -n flux-system reconcile kustomization flux-cluster

  until kubectl -n flux-system wait --for condition=Ready ks/core > /dev/null 2>&1; do
    sleep 5
  done

  flux -n vault suspend helmrelease vault
  flux -n vault suspend helmrelease vault-secrets

  flux suspend kustomization apps
}

configureCeph() {
  echo 'Configuring ceph...'

  until kubectl -n rook-ceph wait --for condition=Available deploy/rook-ceph-osd-0 > /dev/null 2>&1
  do
    sleep 5
  done
}

configureVault() {
  echo 'Configuring vault...'

  flux -n vault resume helmrelease vault

  until kubectl -n vault wait --for condition=Ready pod/vault-0 > /dev/null 2>&1; do
    sleep 5
  done

  vault_init=$(kubectl -n vault exec vault-0 -- vault operator init -n 1 -t 1 -format json)
  unseal_key=$(echo $vault_init | jq -r '.unseal_keys_b64[0]')
  root_token=$(echo $vault_init | jq -r '.root_token')

  echo "Vault unseal key is $unseal_key"
  echo "Vault root token is $root_token"

  kubectl -n vault create secret generic vault-secret \
    --from-literal "VAULT_KEY=$unseal_key" --from-literal "VAULT_TOKEN=$root_token"

  kubectl -n vault exec vault-0 -- vault operator unseal "$unseal_key"

  kubectl -n vault exec vault-0 -- vault login -no-print "$root_token"
  kubectl -n vault exec vault-0 -- vault secrets enable -path=secret -version=2 kv
  kubectl -n vault exec vault-0 -- vault auth enable kubernetes

  kubectl -n vault exec vault-0 -- sh -c \
    'echo -e "path \"secret/data/*\" {\n  capabilities = [\"read\"]\n}" \
      | vault policy write vault-secrets -'
  kubectl -n vault exec vault-0 -- sh -c \
    'vault write auth/kubernetes/config \
      kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443'
  kubectl -n vault exec vault-0 -- sh -c \
    'vault write auth/kubernetes/role/vault-secrets \
      bound_service_account_names=vault-secrets \
      bound_service_account_namespaces=vault \
      policies=vault-secrets \
      ttl=24h'

  kubectl -n vault exec vault-0 -- sh -c \
    "vault kv put secret/flux-system/global $CONFIGURE_VARS"
  kubectl -n vault exec vault-0 -- sh -c \
    "$(curl -s https://raw.githubusercontent.com/chamburr/homelab/main/scripts/vault/secrets.txt)"

  echo "Login to vault at port 8200 to complete installation"
}

postInstall() {
  echo 'Running post install...'

  kubectl -n vault port-forward svc/vault --address=0.0.0.0 8200:8200 &

  firewall-cmd --zone public --add-port 8200/tcp

  kubectl -n vault exec vault-0 -- sh -c \
    "vault kv put secret/INSTALL message='Delete this secret to complete installation'"

  until ! kubectl -n vault exec vault-0 -- sh -c "vault kv get secret/INSTALL" > /dev/null 2>&1; do
    sleep 5
  done

  firewall-cmd --zone public --remove-port 8200/tcp

  flux -n vault resume helmrelease vault-secrets

  sleep 5

  flux resume kustomization apps
}

prepare

if [ "$1" = '' ]; then
  configureTalos
  configureFlux
  configureCeph
  configureVault
elif [ "$1" = '--post' ]; then
  postInstall
fi
