terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.46.0"
    }
  }
  required_version = ">= 0.13"
}

locals {
  now        = timestamp()
  managed    = "Updated by Terraform on ${local.now}"
  expires_at = timeadd(local.now, "5m")
}