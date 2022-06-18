#!/bin/bash

echo "Linting yaml..."
yamllint -c .yamllint.yaml .

echo "Linting ansible..."
ansible-lint -c .ansible-lint.yaml ansible 2>&1 | grep -v "WARNING"

echo "Linting kubernetes..."
mkdir -p /tmp/crd-schemas/master-standalone-strict
curl -sL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz | tar zxf - -C /tmp/crd-schemas/master-standalone-strict
kubeconform -strict -ignore-missing-schema -schema-location default -schema-location /tmp/crd-schemas kubernetes

echo "Linting terraform..."
tflint -c .tflint.hcl terraform
