#!/bin/sh

lintYaml() {
  echo 'Linting yaml...'

  yamllint -c .yamllint.yaml .
}

lintAnsible() {
  echo 'Linting ansible...'

  ansible-lint -c .ansible-lint.yaml ansible 2>&1 | grep -v 'WARNING'
}

lintTerraform() {
  echo 'Linting terraform...'

  tflint terraform
}

lintYaml
lintAnsible
lintTerraform
