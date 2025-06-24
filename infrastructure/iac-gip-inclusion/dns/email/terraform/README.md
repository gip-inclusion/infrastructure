<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | 2.55.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns-email"></a> [dns-email](#module\_dns-email) | ../../../../_modules/dns/records/terraform | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
