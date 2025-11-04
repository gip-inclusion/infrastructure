terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_iam_group" "emplois_cnav" {
  name                = "emplois-cnav"
  description         = var.managed
  external_membership = true
}

resource "scaleway_iam_application" "terraform_ci" {
  name        = "terraform-ci"
  description = var.managed
}

resource "scaleway_iam_api_key" "terraform_ci_api_key" {
  application_id = scaleway_iam_application.terraform_ci.id
  description    = var.managed
  # When authenticating Object Storage operations, SCW uses the default project
  # linked to the API key.
  default_project_id = data.scaleway_account_project.terraform.project_id
}

resource "scaleway_iam_policy" "terraform_ci" {
  name           = "terraform-ci"
  description    = var.managed
  application_id = scaleway_iam_application.terraform_ci.id
  rule {
    organization_id = data.scaleway_account_project.iac_gip_inclusion.organization_id
    permission_set_names = [
      "IAMManager",
      "ProjectManager",
    ]
  }
  # Grant full access to the terraform application for projects managed by Terraform
  rule {
    project_ids = [
      data.scaleway_account_project.iac_gip_inclusion.project_id,
      data.scaleway_account_project.emplois_cnav.project_id,
      data.scaleway_account_project.site_institutionnel_2025.project_id
    ]
    permission_set_names = [
      "AllProductsFullAccess",
    ]
  }
  # Although it is managed by Terraform, this project is meant to store solely Terraform states
  rule {
    project_ids = [data.scaleway_account_project.terraform.project_id]
    permission_set_names = [
      "ObjectStorageFullAccess",
    ]
  }
}

resource "scaleway_iam_policy" "emplois_cnav" {
  name        = "emplois-cnav"
  description = var.managed
  group_id    = scaleway_iam_group.emplois_cnav.id
  rule {
    project_ids = [data.scaleway_account_project.emplois_cnav.project_id]
    permission_set_names = [
      "SecretManagerFullAccess",
    ]
  }
}
