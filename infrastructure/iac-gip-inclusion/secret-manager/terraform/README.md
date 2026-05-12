# Secrets gérés par Terraform pour le GIP Plateforme de l'inclusion

Les secrets relatifs à un projet spécifique n'ont pas leur place ici !

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.60.5 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.60.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_secret.github_backups_api_key](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret) | resource |
| [scaleway_account_project.default](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
