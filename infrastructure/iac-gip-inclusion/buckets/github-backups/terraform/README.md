# Github Backups - Bucket Scaleway

Ce module Terraform crée et configure un bucket Scaleway pour stocker les backups Github de l'infrastructure GIP Inclusion.

https://github.com/gip-inclusion/gh-backups

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.55.0 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.55.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_object_bucket.bucket](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/resources/object_bucket) | resource |
| [scaleway_object_bucket_acl.bucket_acl](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/resources/object_bucket_acl) | resource |
| [scaleway_object_bucket_policy.bucket_policy](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/resources/object_bucket_policy) | resource |
| [scaleway_account_project.default](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/account_project) | data source |
| [scaleway_iam_application.github_backups](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/iam_application) | data source |
| [scaleway_iam_application.terraform_ci](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/iam_application) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
