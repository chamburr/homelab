#!/bin/sh

configureTalos() {
  echo 'Configuring talos...'

  username="${PWD##*/}"

  mkdir .talos .kube
  cd .talos

  curl -O https://raw.githubusercontent.com/chamburr/homelab/master/talos/machines.yaml
  curl -O https://raw.githubusercontent.com/chamburr/homelab/master/talos/patch.yaml

  talosctl gen config cluster https://192.168.122.10:6443 \
    --config-patch @patch.yaml --with-docs=false --with-examples=false

  nodes=$(yq -o=j -I=0 '.nodes[]' machines.yaml)
  endpoints=$(yq '.nodes[] | .endpoint' machines.yaml | xargs)

  for node in $nodes; do
    name=$(echo $node | jq -r '.name')
    endpoint=$(echo $node | jq -r '.endpoint')

    filename="$name.yaml"
    ip=$(virsh net-dhcp-leases default | grep $name | grep -oE '192.168.122.{1,4}')

    cp controlplane.yaml $filename
    sed -i -e "s/\$ENDPOINT/$endpoint/g" -e "s/\$HOSTNAME/$name/g" $filename

    talosctl apply-config -i -n $ip -f $filename

    rm $filename
  done

  talosctl config endpoint $endpoints --talosconfig ./talosconfig
  talosctl config node $endpoints --talosconfig ./talosconfig
  talosctl config merge ./talosconfig

  until talosctl version > /dev/null 2>&1; do
    sleep 5
  done

  talosctl bootstrap -n $(echo $endpoints | cut -f 1 -d ' ')
  talosctl kubeconfig

  rm controlplane.yaml worker.yaml talosconfig
  rm machines.yaml patch.yaml

  cd ..
  chown -R "$username:$username" .talos .kube
}

configureFlux() {
  echo 'Configuring flux...'

  kubectl apply -k 'github.com/chamburr/homelab/kubernetes/base/flux-system?ref=master'

  flux reconcile -n flux-system source git flux-cluster
  flux reconcile -n flux-system kustomization flux-cluster
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

  kubectl -n flux-system create secret generic global-vault-secret \
    --from-literal "VAULT_KEY=$unseal_key" --from-literal "VAULT_TOKEN=$root_token"

  kubectl -n vault exec vault-0 -- vault login -no-print "$root_token"
  kubectl -n vault exec vault-0 -- vault operator unseal "$unseal_key"
  kubectl -n vault exec vault-0 -- vault secrets enable -path=secret -version=2 kv
  kubectl -n vault exec vault-0 -- vault auth enable kubernetes

  kubectl -n vault exec vault-0 -- sh -c \
    'echo "path \"secret/data/*\" {\n  capabilities = [\"read\"]\n}" \
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
    'vault kv put secret/flux-system/global domain= email= \
      cloudflare_email= cloudflare_api_key= cloudflare_zone_id= cloudflare_domain= \
      mail_host= mail_port= mail_username= mail_password= mail_sender='
  kubectl -n vault exec vault-0 -- sh -c \
    'vault kv put secret/developer/drone rpc_secret= github_client_id= github_client_secret=
    vault kv put secret/developer/harbor secret_key=
    vault kv put secret/developer/plausible admin_email=
    vault kv put secret/flux-system/notification token=
    vault kv put secret/flux-system/webhook token=
    vault kv put secret/mail/mailu admin_email= mail_domain= secret_key=
    vault kv put secret/networking/traefik basic_username= basic_password=
    vault kv put secret/security/ipsec-vpn ipsec_psk= username= password=
    vault kv put secret/security/vaultwarden token=
    vault kv put secret/security/wg-easy password=
    vault kv put secret/storage/minio admin_username=
    vault kv put secret/storage/nextcloud admin_username=
    vault kv put secret/storage/samba username= password=
    vault kv put secret/utility/flame password=
    vault kv put secret/utility/kutt admin_emails= jwt_secret=
    vault kv put secret/utility/zipline secret='

  kubectl -n vault exec vault-0 -- rm /home/vault/.vault-token
}

configureTalos
configureFlux
configureVault
