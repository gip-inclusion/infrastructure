terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.55.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_account_project" "terraform" {
  # Use a separate project to prevent terraform from accessing buckets from the
  # default project.
  name = "terraform"
}

resource "scaleway_object_bucket" "gip_inclusion_terraform_state" {
  provider   = scaleway
  name       = "gip-inclusion-state"
  project_id = scaleway_account_project.terraform.id
  versioning { enabled = true }
}

resource "scaleway_object_bucket_acl" "state_bucket_acl" {
  bucket     = scaleway_object_bucket.gip_inclusion_terraform_state.id
  project_id = scaleway_account_project.terraform.id
  acl        = "private"
}

resource "scaleway_object_bucket_policy" "state_bucket_policy" {
  # Configure bucket before to set a restrictive policy.
  depends_on = [scaleway_object_bucket_acl.state_bucket_acl]
  bucket     = scaleway_object_bucket.gip_inclusion_terraform_state.id
  project_id = scaleway_object_bucket.gip_inclusion_terraform_state.project_id
  policy = jsonencode(
    {
      Version = "2023-04-17",
      Statement = [
        {
          Sid    = "Allow Terraform CI to read and write state",
          Effect = "Allow",
          Principal = {
            SCW = [
              "application_id:${data.scaleway_iam_application.terraform_ci.id}",
            ]
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
            scaleway_object_bucket.gip_inclusion_terraform_state.name,
            "${scaleway_object_bucket.gip_inclusion_terraform_state.name}/*"
          ]
        },
      ]
    }
  )
}
