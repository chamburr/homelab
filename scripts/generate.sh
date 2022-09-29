#!/bin/sh

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

generateSecret
