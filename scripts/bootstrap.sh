#!/bin/sh

ansible-galaxy collection install -r ansible/requirements.yml

./scripts/ansible.sh playbook ansible/main.yml --ask-become-pass
