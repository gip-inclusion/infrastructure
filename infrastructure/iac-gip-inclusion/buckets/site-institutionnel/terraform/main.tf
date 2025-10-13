terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.55.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_object_bucket" "uploads_bucket" {
  provider   = scaleway
  name       = "site-institutionnel-2025-uploads"
  project_id = data.scaleway_account_project.site_institutionnel_2025.id
  versioning {
    enabled = true
  }
}

resource "scaleway_object_bucket_acl" "uploads_bucket_acl" {
  bucket     = scaleway_object_bucket.uploads_bucket.id
  project_id = data.scaleway_account_project.site_institutionnel_2025.id
  acl        = "private"
}

resource "scaleway_object_bucket_policy" "uploads_bucket_policy" {
  depends_on = [scaleway_object_bucket_acl.uploads_bucket_acl]
  bucket     = scaleway_object_bucket.uploads_bucket.id
  project_id = scaleway_object_bucket.uploads_bucket.project_id
  policy = jsonencode(
    {
      Version = "2023-04-17",
      Statement = [
        {
          Sid    = "Allow Terraform CI to manage the bucket",
          Effect = "Allow",
          Principal = {
            SCW = [
              "application_id:${data.scaleway_iam_application.terraform_ci.id}",
            ]
          },
          Action = [
            "s3:GetBucketAcl",
            "s3:GetBucketCORS",
            "s3:GetBucketLocation",
            "s3:GetBucketObjectLockConfiguration",
            "s3:GetBucketTagging",
            "s3:GetBucketVersioning",
            "s3:GetBucketWebsite",
            "s3:GetLifecycleConfiguration",
            "s3:SetBucketAcl",
            "s3:SetBucketCORS",
            "s3:SetBucketLocation",
            "s3:SetBucketObjectLockConfiguration",
            "s3:SetBucketTagging",
            "s3:SetBucketVersioning",
            "s3:SetBucketWebsite",
            "s3:SetLifecycleConfiguration",
          ]
          Resource = [
            scaleway_object_bucket.uploads_bucket.name,
          ]
        },
      ]
    }
  )
}
