terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

locals {
  repository = "infrastructure"
}

resource "scaleway_account_project" "terraform" {
  # Use a separate project to prevent terraform from accessing buckets from the
  # default project.
  name = "terraform"
}

resource "scaleway_object_bucket" "gip_inclusion_terraform_state" {
  provider = scaleway
  name = "gip-inclusion-terraform-state"
  project_id = scaleway_account_project.terraform.id
  versioning { enabled = true }
}

resource "scaleway_object_bucket_acl" "state_bucket_acl" {
  bucket = scaleway_object_bucket.gip_inclusion_terraform_state.id
  project_id = scaleway_account_project.terraform.id
  acl = "private"
}

resource "scaleway_object_bucket_policy" "state_bucket_policy" {
  # Configure bucket before to set a restrictive policy.
  depends_on = [scaleway_object_bucket_acl.state_bucket_acl]
  bucket = scaleway_object_bucket.gip_inclusion_terraform_state.id
  project_id = scaleway_object_bucket.gip_inclusion_terraform_state.project_id
  policy = jsonencode(
    {
      Version = "2023-04-17",
      Statement = [
        {
          Sid    = "Allow Terraform CI to read and write state",
          Effect = "Allow",
          Principal = {
            SCW = "application_id:${scaleway_iam_application.terraform_ci.id}"
          },
          Action = [
            # Bucket
            "s3:GetBucketAcl",
            "s3:GetBucketCORS",
            "s3:GetBucketLocation",
            "s3:GetBucketObjectLockConfiguration",
            "s3:GetBucketTagging",
            "s3:GetBucketVersioning",
            "s3:GetBucketWebsite",
            "s3:GetLifecycleConfiguration",
            "s3:ListBucket",
            # Objects
            "s3:GetObject",
            "s3:PutObject",
          ]
          Resource = [
            "${scaleway_object_bucket.gip_inclusion_terraform_state.name}",
            "${scaleway_object_bucket.gip_inclusion_terraform_state.name}/*"
           ]
         },
       ]
     }
   )
 }

resource "scaleway_iam_application" "terraform_ci" {
  name        = "terraform-ci"
  description = var.managed
}

resource "scaleway_iam_api_key" "terraform_ci_api_key" {
  application_id     = scaleway_iam_application.terraform_ci.id
  description        = var.managed
  # When authenticating Object Storage operations, SCW uses the default project
  # linked to the API key.
  default_project_id = scaleway_account_project.terraform.id
}

resource "scaleway_iam_policy" "terraform_ci" {
  name = "terraform-ci"
  description = var.managed
  application_id = scaleway_iam_application.terraform_ci.id
  rule {
    organization_id = var.organization_id
    permission_set_names = [
      "IAMReadOnly",
      # Verify the terraform project existence.
      "ProjectReadOnly",
    ]
  }
  rule {
    project_ids = [var.organization_id]
    permission_set_names = ["DomainsDNSFullAccess"]
  }
  rule {
    project_ids = [scaleway_account_project.terraform.id]
    permission_set_names = ["ObjectStorageFullAccess"]
  }
}

resource "github_actions_secret" "ci_access_key" {
  repository       = local.repository
  secret_name      = "SCW_TF_CI_ACCESS_KEY"
  plaintext_value  = scaleway_iam_api_key.terraform_ci_api_key.access_key
}

resource "github_actions_secret" "ci_secret_key" {
  repository       = local.repository
  secret_name      = "SCW_TF_CI_SECRET_KEY"
  plaintext_value  = scaleway_iam_api_key.terraform_ci_api_key.secret_key
}

resource "github_actions_secret" "ci_organization_id" {
  repository       = local.repository
  secret_name      = "SCW_ORGANIZATION_ID"
  plaintext_value  = var.organization_id
}

output "ci_access_key" {
  value = scaleway_iam_api_key.terraform_ci_api_key.access_key
  sensitive = true
}

output "ci_secret_key" {
  value = scaleway_iam_api_key.terraform_ci_api_key.secret_key
  sensitive = true
}
