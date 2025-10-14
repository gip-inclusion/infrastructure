terraform {
  required_providers {
    scalingo = {
      source  = "Scalingo/scalingo"
      version = "2.6.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scalingo_app" "site" {
  name = "site-institutionnel-2025"

  force_https = true
  stack_id    = ubuntu-24

  environment = {
  }
}

resource "scalingo_addon" "database" {
  provider_id = "scalingo-postgresql"
  plan        = "postgresql-starter-512"
  app         = scalingo_app.site.id
}
