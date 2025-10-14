terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.55.0"
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
    organization_id = data.scaleway_account_project.default.organization_id
    permission_set_names = [
      "IAMManager",
      "ProjectManager",
    ]
  }
  rule {
    project_ids = [data.scaleway_account_project.default.project_id]
    permission_set_names = [
      "DomainsDNSFullAccess",
    ]
  }
  rule {
    project_ids = [data.scaleway_account_project.terraform.project_id]
    permission_set_names = [
      "ObjectStorageFullAccess",
    ]
  }
  rule {
    project_ids = [data.scaleway_account_project.emplois_cnav.project_id]
    permission_set_names = [
      "BlockStorageFullAccess",
      "ContainerRegistryFullAccess",
      "InstancesFullAccess",
      "IPAMFullAccess",
      "KubernetesFullAccess",
      "PrivateNetworksFullAccess",
      "SecretManagerFullAccess",
      "SecretManagerFullAccess",
      "SSHKeysFullAccess",
      "VPCFullAccess",
      "VPCGatewayFullAccess",
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
