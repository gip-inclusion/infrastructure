# Backend Terraform State - Bucket Scaleway

Ce module Terraform crée et configure un bucket Scaleway pour stocker les states Terraform de l'infrastructure GIP Inclusion.

On s'attend à ce que chaque module ait son propre state (fichier distinct) et que le nommage des fichiers de state suive l'arborescence de ce repository.

## Prérequis

- Terraform >= 1.0
- Accès au provider Scaleway configuré
- Variables d'environnement Scaleway définies :

  ```bash
  export SCW_ACCESS_KEY="your-access-key"
  export SCW_SECRET_KEY="your-secret-key"
  export SCW_PROJECT_ID="your-project-id"
  export SCW_ORGANIZATION_ID="your-project-id"
  export SCW_DEFAULT_ORGANIZATION_ID="your-project-id"  # Still required despite the documentation...
  export AWS_ACCESS_KEY_ID=$SCW_ACCESS_KEY
  export AWS_SECRET_ACCESS_KEY=$SCW_SECRET_KEY
  ```

## Architecture

Ce module crée :
- Un projet Scaleway dédié pour isoler les ressources Terraform
- Un bucket S3-compatible avec versioning activé
- Une ACL privée sur le bucket
- Une politique IAM restrictive pour l'application CI/CD

## Initialisation du backend

⚠️ **Attention** : Ce processus doit être exécuté **une seule fois** lors de l'initialisation de l’infrastructure.

En effet, on doit avoir recours à un backend local pour créer ce bucket (puisque l'on ne peut pas push le state avant que le bucket n'existe).  
Une fois initialisé, on peut migrer son state sur S3.

### Étape 1 : Configuration backend local

Créer un fichier `backend.tf` temporaire avec un backend local :

```hcl
terraform {
  backend "local" {}
}
```

### Étape 2 : Création du bucket

```bash
# Initialisation avec backend local
terraform init -reconfigure

# Validation de la configuration
terraform plan

# Création des ressources
terraform apply
```

### Étape 3 : Migration vers le backend S3

1. **Remplacer** le contenu de `backend.tf` par la configuration S3 :

```hcl
terraform {
  backend "s3" {
    bucket                      = "gip-inclusion-state"
    key                         = "iac-gip-inclusion/buckets/iac-gip-inclusion-tfstate/terraform/terraform.tfstate"
    region                      = "fr-par"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    endpoints = {
      s3 = "https://s3.fr-par.scw.cloud"
    }
  }
}
```

2. **Reconfigurer** Terraform pour migrer l'état :

    ```bash
    terraform init -reconfigure
    ```

    Terraform demandera si l'on souhaite copier l'état existant. **Répondre `yes`** :

    ```
    Initializing the backend...
    Do you want to copy existing state to the new backend?
    Pre-existing state was found while migrating the previous "local" backend to the
    newly configured "s3" backend. No existing state was found in the newly
    configured "s3" backend. Do you want to copy this state to the new "s3"
    backend? Enter "yes" to copy and "no" to start with an empty state.

    Enter a value: yes


    Successfully configured the backend "s3"! Terraform will automatically
    use this backend unless the backend configuration changes.
    Initializing provider plugins...
    - Reusing previous version of scaleway/scaleway from the dependency lock file
    - Using previously-installed scaleway/scaleway v2.55.0

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```

3. **Vérifier** que la migration s'est bien déroulée :

    ```bash
    terraform plan
    ```

    On doit obtenir : `No changes. Your infrastructure matches the configuration.`

4. **Retirer** les fichiers du state local :

    ```bash
    rm terraform.tfstate*
    ```

## Sécurité

- Le bucket est configuré en mode privé
- Seule l'application CI/CD autorisée peut accéder au bucket
- Le versioning est activé pour éviter la perte d'états
- Un projet Scaleway dédié isole les ressources (`terraform`)

## Dépannage

### Erreur "Backend configuration changed"

```bash
terraform init -reconfigure
```

### Erreur d'accès au bucket

S'assurer que :
- Les variables d'environnement Scaleway sont correctement définies
- L'application IAM a les bonnes permissions
- Le bucket existe et est accessible

### State corrompu

Si le state est corrompu, il est possible d'utiliser les versions précédentes grâce au versioning :

```bash
# Lister les versions
aws s3api list-object-versions --endpoint-url https://s3.fr-par.scw.cloud --bucket gip-inclusion-state --prefix "iac-gip-inclusion/buckets/iac-gip-inclusion-tfstate/terraform/"

# Restaurer une version précédente
# 1. Identifier la version à restaurer depuis la liste ci-dessus (récupérer le VersionId)
# 2. Télécharger la version spécifique
aws s3api get-object \
  --endpoint-url https://s3.fr-par.scw.cloud \
  --bucket gip-inclusion-state \
  --key "iac-gip-inclusion/buckets/iac-gip-inclusion-tfstate/terraform/terraform.tfstate" \
  --version-id "VERSION_ID_À_RESTAURER" \
  terraform.tfstate.backup

# 3. Sauvegarder le state actuel (au cas où)
terraform state pull > terraform.tfstate.current

# 4. Incrémenter le serial dans le state restauré
# Le serial doit être supérieur au serial actuel pour éviter les conflits

# 5. Pousser la version restaurée avec le nouveau serial
terraform state push terraform.tfstate.backup

# 6. Vérifier que la restauration s'est bien passée
terraform plan

# 7. Retirer les fichiers temporaires
shred -u terraform.tfstate.backup terraform.tfstate.current
```

## Variables importantes

| Variable | Description | Valeur |
|----------|-------------|--------|
| `bucket_name` | Nom du bucket S3 | `gip-inclusion-state` |
| `region` | Région Scaleway | `fr-par` |
| `region` | Zone Scaleway | `fr-par-1` |
| `project_name` | Nom du projet Terraform | `terraform` |

---

⚠️ **Important** : Ce README concerne uniquement l'initialisation du bucket de state. Une fois configuré, ce processus ne doit plus être répété.

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_scaleway"></a> [scaleway](#requirement\_scaleway) | 2.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_scaleway"></a> [scaleway](#provider\_scaleway) | 2.55.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [scaleway_object_bucket.gip_inclusion_terraform_state](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/resources/object_bucket) | resource |
| [scaleway_object_bucket_acl.state_bucket_acl](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/resources/object_bucket_acl) | resource |
| [scaleway_object_bucket_policy.state_bucket_policy](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/resources/object_bucket_policy) | resource |
| [scaleway_account_project.terraform](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/account_project) | data source |
| [scaleway_iam_application.terraform_ci](https://registry.terraform.io/providers/scaleway/scaleway/2.55.0/docs/data-sources/iam_application) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_scw_region"></a> [scw\_region](#input\_scw\_region) | Scaleway region for resources | `string` | n/a | yes |
| <a name="input_scw_zone"></a> [scw\_zone](#input\_scw\_zone) | Scaleway zone for resources | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
