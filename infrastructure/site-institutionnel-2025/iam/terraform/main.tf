terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.55.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_iam_application" "app" {
  name        = "site-institutionnel-2025"
  description = var.managed
}

resource "scaleway_iam_api_key" "api_key" {
  application_id = scaleway_iam_application.app.id
  description    = var.managed
  # When authenticating Object Storage operations, SCW uses the default project
  # linked to the API key.
  default_project_id = data.scaleway_account_project.site_institutionnel_2025.project_id
}

resource "scaleway_iam_policy" "policy" {
  name           = "site-institutionnel-2025"
  description    = var.managed
  application_id = scaleway_iam_application.app.id
  rule {
    project_ids = [data.scaleway_account_project.site_institutionnel_2025.project_id]
    permission_set_names = [
      "ObjectStorageBucketsRead",
      "ObjectStorageObjectsDelete",
      "ObjectStorageObjectsRead",
      "ObjectStorageObjectsWrite",
    ]
  }
}
