resource "cloudflare_zone_settings_override" "settings" {
  zone_id = var.CLOUDFLARE_ZONE_ID
  settings {
    ssl = "strict"

    always_use_https         = "on"
    automatic_https_rewrites = "on"
    opportunistic_encryption = "on"
    tls_1_3                  = "on"

    brotli = "on"
    minify {
      css  = "on"
      html = "on"
      js   = "on"
    }

    always_online    = "off"
    development_mode = "off"

    http2               = "on"
    http3               = "on"
    ipv6                = "on"
    opportunistic_onion = "on"
    websockets          = "on"
    zero_rtt            = "on"

    email_obfuscation   = "off"
    server_side_exclude = "off"
    hotlink_protection  = "off"

    security_header {
      enabled            = true
      preload            = true
      max_age            = 15552000
      no_sniff           = false
      include_subdomains = true
    }
  }
}
