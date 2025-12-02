terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.63.0"
    }
  }
  required_version = ">= 1.10"
}

/*
  We use a dedicated project for the Terraform state bucket to prevent
  Terraform from accessing buckets from the default project.
*/

resource "scaleway_object_bucket" "backups" {
  provider = scaleway
  name     = "backups"
  # Scaleway expiration rules do not operate on objects versions.
  # https://www.scaleway.com/en/docs/object-storage/api-cli/lifecycle-rules-api/#expiration
  versioning { enabled = false }
}

resource "scaleway_object_bucket_acl" "backups_acl" {
  bucket = scaleway_object_bucket.backups.id
  acl    = "private"
}

resource "scaleway_object_bucket_policy" "state_bucket_policy" {
  # Configure bucket before to set a restrictive policy.
  depends_on = [scaleway_object_bucket_acl.backups_acl]
  bucket     = scaleway_object_bucket.backups.id
  policy = jsonencode(
    {
      Version = "2023-04-17",
      Statement = [
        {
          Sid    = "Allow Terraform CI to configure the bucket",
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
            "s3:PutBucketAcl",
            "s3:PutBucketCORS",
            "s3:PutBucketObjectLockConfiguration",
            "s3:PutBucketTagging",
            "s3:PutBucketVersioning",
            "s3:PutBucketWebsite",
            "s3:PutLifecycleConfiguration",
          ]
          Resource = [
            scaleway_object_bucket.backups.name,
          ]
        },
      ]
    }
  )
}
