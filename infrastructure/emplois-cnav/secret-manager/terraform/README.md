## Secrets spécifiques à `emplois-cnav`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.9 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.69.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.74.0 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_secret.api_relay_cnav_database](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret) | resource |
| [scaleway_secret.api_relay_cnav_database_connection](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret) | resource |
| [scaleway_secret.api_relay_cnav_django](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret) | resource |
| [scaleway_secret.argocd_oidc](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret) | resource |
| [scaleway_secret.authentik](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret) | resource |
| [scaleway_secret.cnav_vpn_config](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret) | resource |
| [scaleway_secret_version.api_relay_cnav_database](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret_version) | resource |
| [scaleway_secret_version.api_relay_cnav_django](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret_version) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_relay_environments"></a> [api\_relay\_environments](#input\_api\_relay\_environments) | Environments getting the api-relay application secrets | `set(string)` | n/a | yes |
| <a name="input_database_credentials_versions"></a> [database\_credentials\_versions](#input\_database\_credentials\_versions) | Per-environment database credentials version: bump it to rotate the passwords, then apply emplois-cnav/database to propagate them to the RDB users | `map(number)` | n/a | yes |
| <a name="input_django_secret_key_versions"></a> [django\_secret\_key\_versions](#input\_django\_secret\_key\_versions) | Per-environment Django SECRET\_KEY version: bump it to rotate the key | `map(number)` | n/a | yes |
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
