#!/bin/sh

lintYaml() {
  echo 'Linting yaml...'

  yamllint -c .yamllint.yaml .
}

lintAnsible() {
  echo 'Linting ansible...'

  ansible-lint ansible
}

lintTerraform() {
  echo 'Linting terraform...'

  tflint terraform
}

lintYaml
lintAnsible
lintTerraform
