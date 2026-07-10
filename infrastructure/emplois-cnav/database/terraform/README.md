## Bases de données managées spécifiques à `emplois-cnav`

Une instance PostgreSQL managée **unique et partagée** entre les environnements (à l'image du cluster Kubernetes,
lui aussi partagé), hébergeant une base par environnement pour le backoffice/API relay : `api_relay_cnav_integration`
et `api_relay_cnav_production`.

Conséquences assumées du partage : pas de test possible d'un upgrade de la DB en intégration avant la production
(l'instance monte de version d'un bloc), et ressources CPU/IO/connexions communes aux deux environnements.

### Accès réseau

L'instance est rattachée au Private Network Kubernetes (`emplois-cnav-kubernetes-private-network`)
**sans endpoint public** : seules les ressources du VPC peuvent la joindre.

### Sauvegardes

L'instance étant sur volume Block Storage, les sauvegardes automatiques sont des **snapshots**
(quotidiens, rétention définie via `database_backup_schedule_retention`).
Ils sont stockés dans la même localisation que l'instance : pas de copie multi-AZ ni cross-région
(la HA protège d'une panne de nœud, pas de la perte du site).

Pas de PITR sur le managé Scaleway
([feature request](https://feature-request.scaleway.com/posts/1027/point-in-time-recovery-for-postgresql)) :
le RPO est la fréquence des snapshots (24 h).
Avant une opération en production, considérer d'effectuer un snapshot manuel : `scw rdb snapshot create`.

`backup_same_region = true` garde en France les éventuels backups logiques manuels
(par défaut, Scaleway les stocke dans une autre région, donc hors de France).

### Utilisateurs

Par environnement (`<env>` = `integration` | `production`), sur la base `api_relay_cnav_<env>` :

| Utilisateur | Droits | Usage |
|---|---|---|
| `api_relay_cnav_<env>_jobs` | `all` (DML + DDL) | Jobs : migrations Django / commandes de management |
| `api_relay_cnav_<env>_app` | `readwrite` (DML uniquement) | Pods servant le trafic |

Chaque utilisateur n'a de droits que sur la base de son environnement.

⚠️ Scaleway n'applique le privilège `readwrite` qu'aux objets existants au moment de l'apply
(cf. [permission drift](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_privilege#permission-drift-management)) : il ne sert que de base.

Les grants sur les tables créées ensuite sont posés par le **job de migration** lui-même
(`manage.py grant_app_privileges`, exécuté après `migrate` avec l'utilisateur `_jobs`, propriétaire des objets) :
rattrapage `GRANT ... ON ALL TABLES/SEQUENCES` + `ALTER DEFAULT PRIVILEGES` pour les objets futurs.

Conséquence attendue : l'API peut remonter ce privilège comme `custom`/`drifted` dans les plans.

### Credentials

Les mots de passe des utilisateurs sont générés et stockés dans le module `emplois-cnav/secret-manager`
(secrets `api-relay-database-<env>`), puis **relus ici par une ressource `ephemeral`** pour configurer les users RDB :
ils ne sont **ni committés, ni stockés dans le state** d'aucun des deux modules.
`password_wo_version` dérive du `version_count` du secret : on évite d'avoir à synchroniser une variable de version
entre les modules.

Ce module pousse de son côté l'endpoint de connexion (secret version `api-relay-database-connection-<env>` :
host/port/name, non sensibles), re-poussé automatiquement à chaque changement (ex : recréation d'instance).
L'External Secrets Operator du cluster synchronise les deux secrets dans les namespaces `interops-*` (cf. `emplois-cnav-ops`).

**Rotation** : incrémenter `database_credentials_versions[<env>]` dans `secret-manager` et apply
(nouveaux mots de passe dans le Secret Manager), puis apply **ce module** (les users RDB les reçoivent via
`version_count`).

### Version de PostgreSQL

`database_engine` est défini dans `terraform.tfvars` : vérifier la dernière version disponible avec
`scw rdb engine list`.
La conf de développement (`compose.yaml` d'`api-relay-cnav`) doit s'aligner sur le major maximum supporté côté Scaleway
(PostgreSQL 17 à ce jour, 18 attendu au Q4 2026).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | >= 2.69.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.78.0 |
| <a name="provider_scaleway.tmp"></a> [scaleway.tmp](#provider\_scaleway.tmp) | 2.78.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_rdb_database.api_relay_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_database) | resource |
| [scaleway_rdb_instance.postgresql](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_instance) | resource |
| [scaleway_rdb_privilege.api_relay_cnav_app](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_privilege) | resource |
| [scaleway_rdb_privilege.api_relay_cnav_jobs](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_privilege) | resource |
| [scaleway_rdb_user.api_relay_cnav_app](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_user) | resource |
| [scaleway_rdb_user.api_relay_cnav_jobs](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_user) | resource |
| [scaleway_secret_version.api_relay_cnav_database_connection](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/secret_version) | resource |
| [scaleway_account_project.emplois_cnav](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/account_project) | data source |
| [scaleway_secret.api_relay_cnav_database](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/secret) | data source |
| [scaleway_secret.api_relay_cnav_database_connection](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/secret) | data source |
| [scaleway_vpc_private_network.kubernetes_private_network](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/data-sources/vpc_private_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_backup_schedule_retention"></a> [database\_backup\_schedule\_retention](#input\_database\_backup\_schedule\_retention) | Automated backups retention, in days | `number` | n/a | yes |
| <a name="input_database_engine"></a> [database\_engine](#input\_database\_engine) | Managed PostgreSQL engine version (see `scw rdb engine list`) | `string` | n/a | yes |
| <a name="input_database_environments"></a> [database\_environments](#input\_database\_environments) | Environments getting a database and its pair of users on the shared instance | `set(string)` | n/a | yes |
| <a name="input_database_is_ha_cluster"></a> [database\_is\_ha\_cluster](#input\_database\_is\_ha\_cluster) | Enable high availability on the managed PostgreSQL instance | `bool` | n/a | yes |
| <a name="input_database_node_type"></a> [database\_node\_type](#input\_database\_node\_type) | Node type of the managed PostgreSQL instance | `string` | n/a | yes |
| <a name="input_database_volume_size_in_gb"></a> [database\_volume\_size\_in\_gb](#input\_database\_volume\_size\_in\_gb) | Block storage size of the managed PostgreSQL instance | `number` | n/a | yes |
| <a name="input_managed"></a> [managed](#input\_managed) | Indicates the resource is managed by Terraform | `string` | `"Managed by Terraform"` | no |
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
