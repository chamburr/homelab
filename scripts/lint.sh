#!/bin/sh

lintYaml() {
  echo 'Linting yaml...'

  yamllint .
}

lintAnsible() {
  echo 'Linting ansible...'

  ansible-lint ansible -q
}

lintYaml
lintAnsible
