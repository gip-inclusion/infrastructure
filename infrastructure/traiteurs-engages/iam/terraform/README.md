# Traiteurs engagés - Configuration IAM

Ce module Terraform crée et configure les ressources IAM nécessaires pour
que l'application Traiteurs engagés puisse se connecter au bucket Object
Storage du projet.

Il déclare :

- une **application IAM** dédiée à l'application (servant d'identité
  technique),
- une **clé d'API** liée à cette application — c'est cette clé que
  l'application consomme pour signer ses requêtes S3,
- une **politique IAM** restreinte au projet `traiteurs-engages`, qui
  autorise uniquement les opérations Object Storage nécessaires
  (lecture/écriture/suppression d'objets, lecture du bucket).

La clé d'API est sensible : elle ne doit jamais être committée. Elle se
récupère dans la console Scaleway (ou via `terraform output` si un
output est ajouté ultérieurement) puis se passe à l'application sous
forme de variables d'environnement.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_iam_api_key.api_key](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_api_key) | resource |
| [scaleway_iam_application.app](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_application) | resource |
| [scaleway_iam_policy.policy](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/iam_policy) | resource |
| [scaleway_account_project.traiteurs_engages](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->