terraform {
  required_providers {
    scalingo = {
      source  = "Scalingo/scalingo"
      version = "2.6.0"
    }
  }
  required_version = ">= 1.10"
}

import {
  to = scalingo_app.app
  id = "site-institutionnel-2025"
}

resource "scalingo_app" "app" {
  environment = {
    ALLOWED_HOSTS                  = "site-institutionnel-2025.osc-secnum-fr1.scalingo.io"
    DEFAULT_FROM_EMAIL             = "ne-pas-repondre@inclusion.gouv.fr"
    EMAIL_PORT                     = "587"
    EMAIL_USE_TLS                  = "True"
    HOST_URL                       = "site-institutionnel-2025.osc-secnum-fr1.scalingo.io"
    S3_BUCKET_NAME                 = "site-institutionnel-2025-uploads"
    S3_BUCKET_REGION               = "fr-par"
    S3_HOST                        = "s3.fr-par.scw.cloud"
    S3_LOCATION                    = "site-institutionnel-2025"
    WAGTAIL_PASSWORD_RESET_ENABLED = "True"
  }
  force_https = true
  name        = "site-institutionnel-2025"
  project_id  = "prj-71d5410e-372c-4518-bb72-b106b9a70d6d"
  stack_id    = data.scalingo_stack.scalingo_24.id
}

import {
  to = scalingo_addon.db
  id = "site-institutionnel-2025:ad-174e06fc-f3f3-42bf-b7b2-4279345aaee0"
}

resource "scalingo_addon" "db" {
  app               = scalingo_app.app.id
  database_features = ["force-ssl"]
  plan              = "postgresql-starter-512"
  provider_id       = "postgresql"
}
