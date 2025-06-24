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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_iam_api_key.terraform_ci_api_key](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/resources/iam_api_key) | resource |
| [scaleway_iam_application.terraform_ci](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/resources/iam_application) | resource |
| [scaleway_iam_policy.terraform_ci](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/resources/iam_policy) | resource |
| [scaleway_account_project.default](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/account_project) | data source |
| [scaleway_account_project.terraform](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/account_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ci_access_key"></a> [ci\_access\_key](#output\_ci\_access\_key) | n/a |
| <a name="output_ci_secret_key"></a> [ci\_secret\_key](#output\_ci\_secret\_key) | n/a |
<!-- END_TF_DOCS -->
