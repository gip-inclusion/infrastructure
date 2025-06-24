# Guide de Contribution

Ce document définit les standards et processus pour contribuer à l'infrastructure GIP Inclusion.

## 🎯 Standards de Code

### Structure des Fichiers Terraform

Chaque module Terraform doit respecter cette structure :

```
module-name/
├── terraform/
│   ├── backend.tf        # Configuration du backend S3
│   ├── main.tf           # Ressources principales
│   ├── variables.tf      # Variables d'entrée
│   ├── outputs.tf        # Sorties (optionnel)
│   ├── providers.tf      # Configuration des providers
│   ├── data.tf           # Sources de données (optionnel)
│   ├── locals.tf         # Variables locales (optionnel)
│   ├── terraform.tfvars  # Valeurs des variables (toute valeur sensible **doit** résider dans un vault)
│   └── README.md         # Documentation du module (à terme généré par terraform-docs)
```

### Conventions de Nommage

#### Ressources Terraform

```hcl
# Être concis, mais préserver une hiérarchie dans le nommage des ressources
resource "scaleway_domain_zone" "gip_inclusion_zone_root" {
  domain = "inclusion.gouv.fr"
  subdomain = ""
}

resource "scaleway_domain_zone" "gip_inclusion_zone_emplois" {
  domain = "inclusion.gouv.fr"
  subdomain = "emplois"
}

# Pour les modules
module "dns-emplois" {
  source = "../../_modules/dns/records/terraform"
}

module "dns-marche" {
  source = "../../_modules/dns/records/terraform"
}
```

#### Variables

```hcl
# snake_case pour les variables
variable "zone_domain_name" {
  description = "Nom de domaine de la zone DNS"
  type        = string
}

# Préfixer pour grouper les variables liées
variable "dns_zone_name" {}
variable "dns_record_ttl" {}
```

#### Fichiers et Dossiers
```
# kebab-case pour les noms de dossiers
iac-gip-inclusion/
mon-recap/
buckets/iac-gip-inclusion-tfstate/

# snake_case pour les noms de ressources
bucket_name = "gip-inclusion-state"
domain_name = "inclusion.gouv.fr"
```

### Standards de Documentation

#### Variables

```hcl
variable "example_var" {
  description = "Description claire et concise de la variable"
  type        = string
}
```

Éviter d'utiliser le `default` de la variable : privilégier leur définition dans des fichiers `*.tfvars`.

#### Ressources

```hcl
# Éventuellement ajouter un commentaire pour expliquer la présence de la ressource
resource "scaleway_iam_api_key" "terraform_ci_api_key" {
  application_id = scaleway_iam_application.terraform_ci.id
  description    = var.managed
  # Ajouter un commentaire si la présence d'un attribut n'est pas évident
  default_project_id = data.scaleway_account_project.terraform.project_id
}
```

Utiliser une variable "managed" en tant que description pour indiquer que la ressource est gérée par Terraform dans l'interface SW :

```
variable "managed" {
  type        = string
  description = "Indicates the resource is managed by Terraform"
  default     = "Managed by Terraform"
}
```

#### Outputs

```hcl
output "zone_id" {
  description = "ID de la zone DNS créée"
  value       = scaleway_domain_zone.main.id
  sensitive   = false
}
```

## 🔄 Processus de Contribution

### 1. Préparation

1. **Créer une branche** depuis `main` :
   ```bash
   git switch -c github_username/add-emplois-dns-brevo
   ```

2. **Vérifier que l'environnement soit bien configuré** (cf. [README principal](infrastructure/README.md))

### 2. Développement

1. **Créer/modifier** les fichiers Terraform
2. **Documenter** dans un `README.md` (racine ou du module modifié en fonction des changements)
3. **Valider** le code :

   ```bash
   # Formatage automatique
   terraform fmt -recursive

   # Validation de la syntaxe
   make terraform-validate SERVICE=infrastructure/votre-module

   # Test de planification
   make terraform-plan SERVICE=infrastructure/votre-module
   ```

### 3. Tests

#### Tests obligatoires avant commit

```bash
# 1. Validation de tous les modules
make terraform-validate-all
# 2. Lock des verrous de providers
make terraform-providers-lock-all
```

#### Tests recommandés

```bash
# 1. Plan de tous les modules (en dev uniquement)
make terraform-plan-all

# 2. Vérification de sécurité avec tfsec (si installé)
tfsec .

# 3. Validation des standards avec tflint (si installé)
tflint --recursive
```

### 4. Documentation

1. **README du module** : Créer ou modifier le `README.md` du module
2. **Commentaires dans le code** : Expliquer les choix techniques


## 🚫 Pratiques à Éviter

### ❌ Anti-patterns

```hcl
# Ne jamais hardcoder de secrets
resource "scaleway_object_bucket" "bad" {
  access_key = "SCWXXXXXXXXX"  # ❌ NON !
}

# Ne pas utiliser de magic numbers
resource "scaleway_instance_server" "bad" {
  type = "GP1-XS"
  commercial_type = "GP1-XS"
  enable_ipv6 = true
  image = "ubuntu_focal"  # ❌ ID non reproductible
}
```

### ✅ Bonnes pratiques

```hcl
# Utiliser des variables et data sources
data "scaleway_instance_image" "ubuntu" {
  architecture = "x86_64"
  name         = "Ubuntu 20.04 Focal Fossa"
}

resource "scaleway_instance_server" "good" {
  type  = var.instance_type
  image = data.scaleway_instance_image.ubuntu.id

  tags = var.common_tags
}
```
