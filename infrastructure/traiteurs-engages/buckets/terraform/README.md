# Traiteurs engagés - Bucket pour les fichiers uploadés

Ce module Terraform crée et configure un bucket Object Storage Scaleway
(API S3) pour stocker les fichiers manipulés par l'application
Traiteurs engagés : logos et photos des traiteurs, pièces jointes des
demandes, factures et devis PDF générés, etc.

## Caractéristiques

- **Versioning** activé sur le bucket, pour pouvoir récupérer un objet
  écrasé ou supprimé par mégarde.
- **ACL `private`** : aucun accès public par défaut. Les objets ne
  sortent du bucket que via une URL signée ou via l'application
  authentifiée.
- **Politique IAM ciblée** : deux _statements_ uniquement —
  l'application `traiteurs-engages` (déclarée dans le module IAM voisin)
  peut lire/écrire/supprimer des objets, le `terraform-ci` peut
  administrer la configuration du bucket. Aucun autre principal n'a
  accès.

## Ordre d'apply

Ce module dépend du module `../iam/` (la data source
`scaleway_iam_application.traiteurs_engages` doit pouvoir résoudre).
Apply d'abord `iam/`, puis `buckets/`.

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
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_object_bucket.uploads_bucket](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket) | resource |
| [scaleway_object_bucket_acl.uploads_bucket_acl](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket_acl) | resource |
| [scaleway_object_bucket_policy.uploads_bucket_policy](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/object_bucket_policy) | resource |
| [scaleway_account_project.traiteurs_engages](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |
| [scaleway_iam_application.terraform_ci](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/iam_application) | data source |
| [scaleway_iam_application.traiteurs_engages](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/iam_application) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->