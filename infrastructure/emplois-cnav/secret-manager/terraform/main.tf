terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_secret" "cnav_vpn_config" {
  name        = "cnav-vpn-config"
  protected   = true
  description = var.managed
  type        = "key_value"
}
