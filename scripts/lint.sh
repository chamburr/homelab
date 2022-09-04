#!/bin/sh

lintYaml() {
  echo 'Linting yaml...'

  yamllint -c .yamllint.yaml .
}

lintAnsible() {
  echo 'Linting ansible...'

  ansible-lint -c .ansible-lint.yaml ansible 2>&1 | grep -v 'WARNING'
}

lintKubernetes() {
  echo 'Linting kubernetes...'

  mkdir -p /tmp/crd-schemas/master-standalone-strict
  curl -sL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz \
    | tar zxf - -C /tmp/crd-schemas/master-standalone-strict
  kubeconform -strict -ignore-missing-schemas \
    -schema-location default -schema-location /tmp/crd-schemas kubernetes
  rm -rf /tmp/crd-schemas
}

lintTerraform() {
  echo 'Linting terraform...'

  tflint -c .tflint.hcl terraform
}

lintYaml
lintAnsible
lintKubernetes
lintTerraform
