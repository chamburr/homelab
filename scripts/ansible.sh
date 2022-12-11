#!/bin/sh

prepare() {
  user=$(grep ^USER= .env | cut -d '=' -f2-)
  password=$(grep ^PASSWORD= .env | cut -d '=' -f2-)

  args=''

  if [ "$user" != '' ]; then
    args="ansible_user='$user'"
    if [ "$password" != '' ]; then
      args="$args ansible_password='$password'"
    fi
  fi
}

run() {
  if [ "$1" = 'playbook' ]; then
    shift 1
    ansible-playbook -i ansible/hosts.yml -e "$args" "$@"
  else
    ansible -i ansible/hosts.yml -e "$args" "$@"
  fi
}

prepare
run "$@"
