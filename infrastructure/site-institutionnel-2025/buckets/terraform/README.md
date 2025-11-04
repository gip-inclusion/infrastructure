# Site institutionnel - Bucket pour les fichiers du CMS

Ce module Terraform crée et configure un bucket Scaleway pour stocker les fichiers statiques du site institutionnel.

## Prérequis

- Terraform >= 1.0
- Accès au provider Scaleway configuré

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.55.0 |

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
| [scaleway_object_bucket.uploads_bucket](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket) | resource |
| [scaleway_object_bucket_acl.uploads_bucket_acl](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket_acl) | resource |
| [scaleway_object_bucket_policy.uploads_bucket_policy](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket_policy) | resource |
| [scaleway_account_project.site_institutionnel_2025](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |
| [scaleway_iam_application.site_institutionnel_2025](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/iam_application) | data source |
| [scaleway_iam_application.terraform_ci](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/iam_application) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
