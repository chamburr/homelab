#!/bin/sh

echo 'Generating cilium files...'

helm template cilium cilium/cilium -n kube-system -f talos/cilium/values.yaml \
  > talos/cilium/install.yaml

echo 'Generating secret files...'

data=''

for file in $(find . -type f -name 'secret.yaml'); do
  if [ "$(cat $file | yq 'select(.kind == "VaultSecret")')" = '' ]; then
    continue
  fi

  path=$(cat $file | yq 'select(.kind == "VaultSecret").spec.path')
  keys=$(cat $file | yq 'select(.kind == "VaultSecret").spec.keys | join("= ")')
  keys+='='

  data+="vault kv put $path $keys\n"
done

echo "${data%??}" > scripts/secrets.txt
