data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

resource "cloudflare_record" "root" {
  zone_id = var.CLOUDFLARE_ZONE_ID
  name    = "@"
  type    = "A"
  value   = chomp(data.http.ipv4.response_body)
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "wildcard" {
  zone_id = var.CLOUDFLARE_ZONE_ID
  name    = "*"
  type    = "CNAME"
  value   = var.CLOUDFLARE_DOMAIN
  ttl     = 1
  proxied = false
}
