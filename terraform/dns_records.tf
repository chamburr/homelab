data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

resource "cloudflare_record" "root" {
  zone_id = vars.CLOUDFLARE_ZONE_ID
  name    = "@"
  type    = "A"
  value   = chomp(data.http.ipv4.response_body)
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "wildcard" {
  zone_id = vars.CLOUDFLARE_ZONE_ID
  name    = "*"
  type    = "CNAME"
  value   = vars.CLOUDFLARE_DOMAIN
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "vpn" {
  zone_id = vars.CLOUDFLARE_ZONE_ID
  name    = "vpn"
  type    = "CNAME"
  value   = vars.CLOUDFLARE_DOMAIN
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "smb" {
  zone_id = vars.CLOUDFLARE_ZONE_ID
  name    = "smb"
  type    = "CNAME"
  value   = vars.CLOUDFLARE_DOMAIN
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "imap" {
  zone_id = vars.CLOUDFLARE_ZONE_ID
  name    = "imap"
  type    = "CNAME"
  value   = vars.CLOUDFLARE_DOMAIN
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "smtp" {
  zone_id = vars.CLOUDFLARE_ZONE_ID
  name    = "smtp"
  type    = "CNAME"
  value   = "TODO.mxrouting.net"
  ttl     = 1
  proxied = false
}
