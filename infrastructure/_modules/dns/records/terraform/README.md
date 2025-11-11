<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | >= 2.55.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_domain_record.records](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/domain_record) | resource |
| [scaleway_domain_zone.zone](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/domain_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_records"></a> [records](#input\_records) | DNS records in the zone. The ID must be unique. | <pre>map(object({<br/>    name     = string<br/>    data     = string<br/>    type     = string<br/>    ttl      = optional(number, 3600)<br/>    priority = optional(number, 0)<br/>  }))</pre> | n/a | yes |
| <a name="input_scw_project_id"></a> [scw\_project\_id](#input\_scw\_project\_id) | Scaleway project\_id for resources | `string` | n/a | yes |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
