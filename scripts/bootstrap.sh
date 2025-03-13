#!/bin/sh

prepare() {
  ansible-galaxy collection install -r ansible/requirements.yml > /dev/null
}

install() {
  echo 'Installing...'

  username=$(grep ^USERNAME= .env | cut -d '=' -f2-)
  password=$(grep ^PASSWORD= .env | cut -d '=' -f2-)

  args=''

  if [ "$username" != '' ]; then
    args="ansible_user='$username'"
    if [ "$password" != '' ]; then
      args="$args ansible_password='$password'"
    fi
  fi

  ansible-playbook -i ansible/hosts.yml -e "$args" ansible/main.yml --tags common

  export DOCKER_USERNAME=$(grep ^DOCKER_USERNAME= .env | cut -d '=' -f2-)
  export DOCKER_PASSWORD=$(grep ^DOCKER_PASSWORD= .env | cut -d '=' -f2-)

  ansible-playbook -i ansible/hosts.yml ansible/main.yml --skip-tags common
}

prepare
install
