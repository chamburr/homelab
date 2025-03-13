#!/bin/sh

lintYaml() {
  echo 'Linting yaml...'

  yamllint -s .
}

lintAnsible() {
  echo 'Linting ansible...'

  ansible-lint -q ansible
}

lintYaml
lintAnsible
