## Container registry spécifique à `emplois-cnav`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.60.3 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.60.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_registry_namespace.emplois_cnav_registry](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/registry_namespace) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |

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
