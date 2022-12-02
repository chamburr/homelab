#!/bin/sh

prepare() {
  ansible-galaxy collection install -r ansible/requirements.yml
}

install() {
  echo "Installing..."

  ./scripts/ansible.sh playbook ansible/main.yml --tags common

  sed -i \
    -e "s/^USER=.*/USER=$(cat ansible/group_vars/all.yml | yq '.username')/" \
    -e "s/^PASSWORD=.*/PASSWORD=/" \
    .env

  export CONFIGURE_VARS=$(cat .env | grep '=' \
   | grep -v -e '^USER=' -e '^PASSWORD=' | sed 's/\(.*\)=/\L\1=/' | xargs)

  ./scripts/ansible.sh playbook ansible/main.yml --skip-tags common
}

install
