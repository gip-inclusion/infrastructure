# DNS — Traiteurs engagés

Enregistrements DNS pour le service "Traiteurs engagés".

Les records étaient initialement définis dans le module `dns/gip-inclusion`, ils ont été extraits dans ce module dédié.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.75.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns-traiteurs-engages"></a> [dns-traiteurs-engages](#module\_dns-traiteurs-engages) | ../../../../_modules/dns/records/terraform | n/a |

## Resources

| Name | Type |
|------|------|
| [scaleway_account_project.iac_gip_inclusion](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
