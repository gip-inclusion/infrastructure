terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.55.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_object_bucket" "bucket" {
  provider = scaleway
  name     = "github-backups"
  versioning { enabled = true }
}

resource "scaleway_object_bucket_acl" "bucket_acl" {
  bucket = scaleway_object_bucket.bucket.id
  acl    = "private"
}

resource "scaleway_object_bucket_policy" "bucket_policy" {
  depends_on = [scaleway_object_bucket_acl.bucket_acl]
  bucket     = scaleway_object_bucket.bucket.id
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
            ],
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
            "s3:ListBucket",
            "s3:ListBucketVersions",
            "s3:PutBucketAcl",
            "s3:PutBucketCORS",
            "s3:PutBucketObjectLockConfiguration",
            "s3:PutBucketTagging",
            "s3:PutBucketVersioning",
            "s3:PutBucketWebsite",
            "s3:PutLifecycleConfiguration",
          ],
          Resource = [
            scaleway_object_bucket.bucket.name,
          ],
        },
        {
          Sid    = "Allow Github Backups to store and retrieve objects in the bucket",
          Effect = "Allow",
          Principal = {
            SCW = [
              "application_id:${data.scaleway_iam_application.github_backups.id}",
            ]
          },
          Action = [
            # Objects
            "s3:GetObject",
            "s3:PutObject",
          ]
          Resource = [
            "${scaleway_object_bucket.bucket.name}/*"
          ]
        },
      ]
    }
  )
}
