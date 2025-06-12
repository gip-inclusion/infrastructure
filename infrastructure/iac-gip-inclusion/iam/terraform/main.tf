terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.55.0"
    }
  }
  required_version = ">= 1.10"
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
    organization_id = var.scw_organization_id
    permission_set_names = [
      "IAMReadOnly",
      # Verify the terraform project existence.
      "ProjectReadOnly",
    ]
  }
  rule {
    project_ids = [var.scw_organization_id]
    permission_set_names = [
      "DomainsDNSFullAccess",
      "BlockStorageFullAccess",
      "ContainerRegistryFullAccess",
      "IPAMFullAccess",
      "InstancesFullAccess",
      "KubernetesFullAccess",
      "PrivateNetworksFullAccess",
      "SecretManagerFullAccess",
      "VPCFullAccess",
      "VPCGatewayFullAccess",
    ]
  }
  rule {
    project_ids          = [data.scaleway_account_project.terraform.project_id]
    permission_set_names = ["ObjectStorageFullAccess"]
  }
}
