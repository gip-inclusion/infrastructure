terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.55.0"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_object_bucket" "uploads_bucket" {
  provider = scaleway
  name     = "traiteurs-engages-uploads"
  versioning {
    enabled = true
  }
}

resource "scaleway_object_bucket_acl" "uploads_bucket_acl" {
  bucket = scaleway_object_bucket.uploads_bucket.id
  acl    = "private"
}

resource "scaleway_object_bucket_policy" "uploads_bucket_policy" {
  depends_on = [scaleway_object_bucket_acl.uploads_bucket_acl]
  bucket     = scaleway_object_bucket.uploads_bucket.id
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
            scaleway_object_bucket.uploads_bucket.name,
          ],
        },
        {
          Sid    = "Allow the traiteurs-engages app to store and retrieve objects in the bucket",
          Effect = "Allow",
          Principal = {
            SCW = [
              "application_id:${data.scaleway_iam_application.traiteurs_engages.id}",
            ],
          },
          Action = [
            # Bucket permissions
            "s3:ListBucket",

            # Object permissions
            "s3:AbortMultipartUpload",
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:PutObject",
          ],
          Resource = [
            "${scaleway_object_bucket.uploads_bucket.name}",
            "${scaleway_object_bucket.uploads_bucket.name}/*",
          ],
        },
      ],
    },
  )
}
