## IAM spécifique à `emplois-cnav`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | 2.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.60.0 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.60.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_iam_ssh_key.leo](https://registry.terraform.io/providers/scaleway/scaleway/2.60.0/docs/resources/iam_ssh_key) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/2.60.0/docs/data-sources/account_project) | data source |

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
