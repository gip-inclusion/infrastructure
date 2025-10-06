## Instance Strongswan de emplois-cnav

Permet d'assurer la liaison IPSec avec la CNAV.

### Ajout de la PSK

La PSK doit être définie manuellement dans l'instance (`/etc/ipsec.secrets`), faute de pouvoir le faire de manière sécurisée depuis Terraform / Scaleway.  
En effet, elle a beau être stockée dans le secret manager, elle se retouve exposée à un moment ou un autre en clair dans le cloud-init (en base64, mais donc également visible de tous dans la console SW).  
L'idéal aurait été de pouvoir monter le secret en tant qu'env var / fichier dans l'instance.

TODO à moyen terme :
- Tout rappatrier ce qui est relatif à la CNAV sur un projet dédié pour mieux circonscrire les permissions (`emplois-cnav`, actuellement tout est sur `default` vu qu'on avait réservé les IP sur ce projet)
    - Ça imposera un changement d'IP du public gateway (qui ne peut être partagé sur différents projets chez Scaleway)
- Trouver le moyen de limiter qui a accès à l'instance via SSH
    - Actuellement toutes les clés ssh semblent ajoutées aux `authorized_keys` du bastion (public gateway) et de l'instance
    - A priori possible via cloud-init, idéalement en se basant sur des ressource terraform SSH

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |

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
| [scaleway_instance_private_nic.strongswan_instance_private_nic](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_private_nic) | resource |
| [scaleway_instance_security_group.strongswan_security_group](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_security_group) | resource |
| [scaleway_instance_server.strongswan_instance](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/instance_server) | resource |
| [scaleway_ipam_ip.strongswan_instance_private_network_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/ipam_ip) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |
| [scaleway_secret_version.cnav_vpn_config](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/secret_version) | data source |
| [scaleway_vpc_private_network.private_network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/vpc_private_network) | data source |
| [scaleway_vpc_public_gateway.strongswan_public_gateway](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/vpc_public_gateway) | data source |
| [scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/vpc_public_gateway_ip) | data source |

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
