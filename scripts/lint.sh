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

  tflint --chdir terraform
}

lintYaml
lintAnsible
lintTerraform
