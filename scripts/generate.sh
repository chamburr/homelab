#!/bin/sh

generateMachine() {
  echo 'Generating machine files...'

  data="---\n"
  data+=$(cat ansible/roles/kubernetes/defaults/main.yml \
    | yq '.vms | to_entries' | sed -e 's/key/name/' -e 's/value/endpoint/')

  echo "$data" > scripts/talos/machines.yaml
}

generateCilium() {
  echo 'Generating cilium files...'

  helm template cilium cilium/cilium --version 1.11.2 \
    -n kube-system -f scripts/cilium/values.yaml > scripts/cilium/install.yaml
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

generateMachine
generateCilium
generateSecret
