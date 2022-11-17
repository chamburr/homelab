#!/bin/sh

lintYaml() {
  echo 'Linting yaml...'

  yamllint .
}

lintAnsible() {
  echo 'Linting ansible...'

  ansible-lint ansible -q
}

lintTerraform() {
  echo 'Linting terraform...'

  tflint terraform
}

lintYaml
lintAnsible
lintTerraform
