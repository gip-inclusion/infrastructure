# Infrastructure GIP Inclusion

Infrastructure as Code (IaC) pour le déploiement de l'infrastructure GIP Inclusion sur Scaleway.


## 🚀 Démarrage rapide

### Prérequis

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- Compte Scaleway avec les permissions appropriées
- Make (pour utiliser les raccourcis)

### Configuration initiale

1. **Configurer les variables d'environnement Scaleway :**

   ```bash
   export SCW_ACCESS_KEY="your-access-key"
   export SCW_SECRET_KEY="your-secret-key"
   export SCW_PROJECT_ID="your-project-id"
   export SCW_ORGANIZATION_ID="your-project-id"
   export SCW_DEFAULT_ORGANIZATION_ID="your-project-id"  # Still required despite the documentation...
   export AWS_ACCESS_KEY_ID=$SCW_ACCESS_KEY
   export AWS_SECRET_ACCESS_KEY=$SCW_SECRET_KEY
   ```

2. **Initialiser le backend de state** (une seule fois) :

   ```bash
   cd infrastructure/iac-gip-inclusion/buckets/iac-gip-inclusion-tfstate/terraform/
   # Suivre les instructions du README.md local
   ```

   📝 [README du bucket de state](infrastructure/iac-gip-inclusion/buckets/iac-gip-inclusion-tfstate/terraform/README.md)


## 🏗️ Ressources

**Aucune ressource dans le projet par défaut** (qui a le même UUID que
l’organisation).

Le projet par défaut est utilisé par les utilisateurs console,
ce qui conduit à un risque important de _drift_ (un utilisateur modifie une
ressource en console sans mettre à jour le _state_ Terraform), et diminue les
bénéfices de l’IaC :

- la déclaration n’est pas l’état réel de la ressource, rendant la documentation inexacte,
- peut conduire Terraform à effectuer des opérations incorrectes sur les ressources.

La seule exception à cette règle concerne les enregistrements DNS, car la zone
racine **doit** être située dans le projet par défaut (limitation confirmée par
le support Scaleway).

La gestion des ressources organisationnelles (IAM, projets) se fait dans le
module `infrastructure/organization/`.

Les autres ressources sont déclarées dans un projet dédié. Si les ressources
sont transverses, elles se situent dans `infrastructure/iac-gip-inclusion/`.
Chaque produit peut également créer des projets pour organiser ses ressources.

## 📝 Utilisation

### Commandes Make disponibles

Le makefile permet d'automatiser les commandes Terraform module par module :
- En se déplaçant dans chaque module
- Faisant appel à tfswitch pour avoir une version de Terraform en adéquation avec les contraintes du module (si disponible)
- Faisant un `init -reconfigure` pour modifier la config du backend (si elle a changé)
- Faisant l'action demandée (validate, plan, apply, etc.)
- Revenant au répertoire racine d'origine

```bash
# Voir toutes les commandes disponibles
make help

# Valider toute la configuration Terraform
make terraform-validate-all

# Planifier les changements
make terraform-plan SERVICE=infrastructure/iac-gip-inclusion/iam

# Appliquer les changements
make terraform-apply SERVICE=infrastructure/iac-gip-inclusion/dns/emplois
```

### Actions directes depuis les modules

Chaque module peut être géré indépendamment :

```bash
# Configuration des zones DNS
cd iac-gip-inclusion/dns/zones/terraform/
terraform plan
terraform apply

# Configuration IAM
cd iac-gip-inclusion/iam/terraform/
terraform plan
terraform apply
```

## 🔧 Modules réutilisables

À placer à la racine dans `/_modules/`

### Module DNS Records (`_modules/dns/records/`)

Module réutilisable pour créer des enregistrements DNS.


## 🔐 Sécurité

- **États Terraform** : Stockés dans un bucket Scaleway privé avec versioning
- **IAM** : Politiques restrictives par service
- **Secrets** : Variables d'environnement uniquement, jamais dans le code, utiliser des références vers un vault pour tout ce qui est sensible


## 🛟 Support

- **Documentation Scaleway** : https://www.scaleway.com/en/docs/
- **Documentation Terraform** : https://www.terraform.io/docs/
- **Issues** : Créer une issue GitHub pour signaler un problème

## 🤝 Contribution

Voir le [guide dédié](CONTRIBUTING.md).
