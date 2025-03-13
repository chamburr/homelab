#!/bin/sh

until vault status > /dev/null 2>&1 || test $? -ne 1; do
  sleep 1
done

if [ -f /vault/data/keys.txt ]; then
  unseal_key=$(cat /vault/data/keys.txt | sed 's/.*: //g' | head -n 1)
  vault operator unseal "$unseal_key" > /dev/null
  exit 0
fi

vault operator init -n 1 -t 1 | grep ":" > /vault/data/keys.txt

unseal_key=$(cat /vault/data/keys.txt | sed 's/.*: //g' | head -n 1)
root_token=$(cat /vault/data/keys.txt | sed 's/.*: //g' | head -n 2 | tail -n 1)

vault operator unseal "$unseal_key" > /dev/null
vault login -no-print "$root_token"
vault secrets enable -path=secret -version=2 kv

cat <<EOF | vault policy write external-secrets -
path "secret/data/*" {
  capabilities = ["read"]
}
EOF

vault auth enable kubernetes
vault write auth/kubernetes/config \
  kubernetes_host=https://${KUBERNETES_PORT_443_TCP_ADDR}:443
vault write auth/kubernetes/role/external-secrets \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=system \
  policies=external-secrets \
  ttl=24h
