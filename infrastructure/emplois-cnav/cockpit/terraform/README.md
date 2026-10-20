## Cockpit (service d'observabilité de Scaleway) de `emplois-cnav`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.69.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.87.0 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.87.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_cockpit_source.kubernetes_logs](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/cockpit_source) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubernetes_logs_retention_days"></a> [kubernetes\_logs\_retention\_days](#input\_kubernetes\_logs\_retention\_days) | Number of days the logs of the Kubernetes cluster are kept | `number` | n/a | yes |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
