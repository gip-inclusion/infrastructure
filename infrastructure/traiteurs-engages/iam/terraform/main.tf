terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_iam_application" "app" {
  name        = "traiteurs-engages"
  description = var.managed
}

resource "scaleway_iam_api_key" "api_key" {
  application_id = scaleway_iam_application.app.id
  description    = var.managed
  # When authenticating Object Storage operations, SCW uses the default project
  # linked to the API key.
  default_project_id = data.scaleway_account_project.traiteurs_engages.project_id
}

resource "scaleway_iam_policy" "policy" {
  name           = "traiteurs-engages"
  description    = var.managed
  application_id = scaleway_iam_application.app.id
  rule {
    project_ids = [data.scaleway_account_project.traiteurs_engages.project_id]
    permission_set_names = [
      "ObjectStorageBucketsRead",
      "ObjectStorageObjectsDelete",
      "ObjectStorageObjectsRead",
      "ObjectStorageObjectsWrite",
    ]
  }
}

import {
  to = scaleway_iam_api_key.api_key
  id = "SCWY29BKPXVB49663RGX"
}

resource "scaleway_iam_application" "app_production" {
  name        = "traiteurs-engages-production"
  description = var.managed
}

resource "scaleway_iam_policy" "policy_production" {
  name           = "traiteurs-engages-production"
  description    = var.managed
  application_id = scaleway_iam_application.app_production.id
  rule {
    project_ids = [data.scaleway_account_project.traiteurs_engages.project_id]
    permission_set_names = [
      "ObjectStorageBucketsRead",
      "ObjectStorageObjectsDelete",
      "ObjectStorageObjectsRead",
      "ObjectStorageObjectsWrite",
    ]
  }
}
