## Projets utilisés par l'IAC

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.69.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/account_project) | resource |
| [scaleway_account_project.iac_gip_inclusion](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/account_project) | resource |
| [scaleway_account_project.site_institutionnel_2025](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/account_project) | resource |
| [scaleway_account_project.terraform](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/account_project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_default_region"></a> [scw\_default\_region](#input\_scw\_default\_region) | Default Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_default_zone"></a> [scw\_default\_zone](#input\_scw\_default\_zone) | Default Scaleway zone for resources | `string` | n/a | yes |
| <a name="input_scw_organization_id"></a> [scw\_organization\_id](#input\_scw\_organization\_id) | ID of the Scaleway organization | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
