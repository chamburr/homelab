#!/bin/sh

generateCilium() {
  echo 'Generating cilium files...'

  helm template cilium cilium/cilium --version 1.11.2 \
    -n kube-system -f scripts/cilium/values.yaml > scripts/cilium/install.yaml

  prettier -w scripts/cilium/install.yaml > /dev/null
}

generateSecret() {
  echo 'Generating secret files...'

  data=''

  for file in $(find . -type f -name 'secret.yaml'); do
    secret=$(cat $file | yq 'select(.kind == "VaultSecret")')

    if [ "$secret" = '' ]; then
      continue
    fi

    name=$(echo "$secret" | yq '.metadata.name')

    if [ "$name" = 'global-secret' ]; then
      continue
    fi

    path=$(echo "$secret" | yq '.spec.path')
    keys=$(echo "$secret" | yq '.spec.keys | join("= ")')
    keys+='='

    data+="vault kv put $path $keys\n"
  done

  echo "${data%??}" > scripts/vault/secrets.txt
}

generateCilium
generateSecret
