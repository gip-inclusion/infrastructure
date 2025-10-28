# Configuration Github du dépôt `gh-backups`


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.6.0 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.6.0 |
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.55.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_actions_environment_secret.github_s3_access_key](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_secret.github_s3_secret_key](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_variable.github_bucket_name](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/actions_environment_variable) | resource |
| [github_actions_environment_variable.github_organization_name](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/actions_environment_variable) | resource |
| [github_actions_environment_variable.github_s3_endpoint](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/actions_environment_variable) | resource |
| [github_actions_environment_variable.github_s3_region](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/actions_environment_variable) | resource |
| [github_repository.github_backups](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/repository) | resource |
| [github_repository_environment.prod](https://registry.terraform.io/providers/integrations/github/6.6.0/docs/resources/repository_environment) | resource |
| [scaleway_account_project.default](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/account_project) | data source |
| [scaleway_object_bucket.github_backups](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/object_bucket) | data source |
| [scaleway_secret_version.github_backups_api_key](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | Github owner (organization) | `string` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | Github repository | `string` | n/a | yes |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
