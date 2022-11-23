#!/bin/sh

prepare() {
  user=$(grep ^USER= .env | cut -d '=' -f2-)
  password=$(grep ^PASSWORD= .env | cut -d '=' -f2-)

  args='-i ansible/hosts.yml'

  if [ "$user" != '' ]; then
    args="$args -u '$user'"
  fi

  if [ "$password" != '' ]; then
    args="$args -e 'ansible_password=$password'"
  fi
}

run() {
  if [ "$1" = 'playbook' ]; then
    shift 1
    eval "ansible-playbook $args $@"
  else
    eval "ansible $args $@"
  fi
}

prepare
run $@
