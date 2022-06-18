#!/bin/sh

formatYaml() {
  echo 'Formatting yaml...'

  prettier -cw .
}

formatYaml
