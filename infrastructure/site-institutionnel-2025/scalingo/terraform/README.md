# Site institutionnel - Configuration Scalingo

Ce module Terraform crée et configure une app Scalingo pour servir le site
institutionnel. Le site est construit sur la base de
https://github.com/numerique-gouv/sites-faciles.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scalingo"></a> [scalingo](#requirement\_scalingo) | 2.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scalingo"></a> [scalingo](#provider\_scalingo) | 2.6.0 |
| <a name="provider_scalingo.tmp"></a> [scalingo.tmp](#provider\_scalingo.tmp) | 2.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scalingo_addon.db](https://registry.terraform.io/providers/Scalingo/scalingo/2.6.0/docs/resources/addon) | resource |
| [scalingo_app.app](https://registry.terraform.io/providers/Scalingo/scalingo/2.6.0/docs/resources/app) | resource |
| [scalingo_region.secnum_cloud](https://registry.terraform.io/providers/Scalingo/scalingo/2.6.0/docs/data-sources/region) | data source |
| [scalingo_stack.scalingo_24](https://registry.terraform.io/providers/Scalingo/scalingo/2.6.0/docs/data-sources/stack) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scalingo_api_token"></a> [scalingo\_api\_token](#input\_scalingo\_api\_token) | API token to connect to Scalingo | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
