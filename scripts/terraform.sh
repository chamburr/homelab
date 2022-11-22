#!/bin/sh

prepare() {
  export TF_VAR_CLOUDFLARE_EMAIL=$(grep CLOUDFLARE_EMAIL= .env | cut -d '=' -f2-)
  export TF_VAR_CLOUDFLARE_API_KEY=$(grep CLOUDFLARE_API_KEY= .env | cut -d '=' -f2-)
  export TF_VAR_CLOUDFLARE_ZONE_ID=$(grep CLOUDFLARE_ZONE_ID= .env | cut -d '=' -f2-)
  export TF_VAR_CLOUDFLARE_DOMAIN=$(grep CLOUDFLARE_DOMAIN= .env | cut -d '=' -f2-)
}

run() {
  terraform -chdir=terraform $@
}

prepare
run
