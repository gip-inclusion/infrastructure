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
