#!/bin/sh

if [ "$1" = 'playbook' ]; then
  shift 1
  ansible-playbook -i ansible/hosts.yml $@
else
  ansible -i ansible/hosts.yml $@
fi
