# Bucket de sauvegarde

Ce module Terraform crée et configure un bucket Scaleway pour stocker les
sauvegardes des produits et outils de la Plateforme de l’inclusion.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.63.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.63.0 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.63.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_object_bucket.backups](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket) | resource |
| [scaleway_object_bucket_acl.backups_acl](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket_acl) | resource |
| [scaleway_object_bucket_policy.state_bucket_policy](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket_policy) | resource |
| [scaleway_account_project.iac_gip_inclusion](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
