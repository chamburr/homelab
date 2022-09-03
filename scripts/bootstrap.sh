#!/bin/sh

ansible-galaxy collection install -r ansible/requirements.yml

./scripts/ansible.sh playbook ansible/main.yml --tags common

sed -i \
  -e "s/USER=.*/USER=$(cat ansible/group_vars/all.yml | yq '.username')/" \
  -e "s/PASSWORD=.*/PASSWORD=/" \
  .env

./scripts/ansible.sh playbook ansible/main.yml --skip-tags common
