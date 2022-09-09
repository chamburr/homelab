#!/bin/sh

deps() {
  ansible-galaxy collection install -r ansible/requirements.yml
}

prepare() {
  ./scripts/ansible.sh playbook ansible/main.yml --tags common

  sed -i \
    -e "s/^USER=.*/USER=$(cat ansible/group_vars/all.yml | yq '.username')/" \
    -e "s/^PASSWORD=.*/PASSWORD=/" \
    .env
}

install() {
  export CONFIGURE_VARS=$(cat .env | grep '=' \
   | grep -v -e '^USER=' -e '^PASSWORD=' | sed 's/\(.*\)=/\L\1=/' | xargs)

  ./scripts/ansible.sh playbook ansible/main.yml --skip-tags common
}

deps
prepare
install
