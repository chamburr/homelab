terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.16.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.2.0"
    }
  }
}

variable "CLOUDFLARE_EMAIL" {
  type = string
}

variable "CLOUDFLARE_API_KEY" {
  type = string
}

variable "CLOUDFLARE_ZONE_ID" {
  type = string
}

variable "CLOUDFLARE_DOMAIN" {
  type = string
}

provider "cloudflare" {
  email   = var.CLOUDFLARE_EMAIL
  api_key = var.CLOUDFLARE_API_KEY
}
