terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.69.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.9"
    }
  }
  required_version = ">= 1.11"
}

resource "scaleway_secret" "cnav_vpn_config" {
  name        = "cnav-vpn-config"
  protected   = true
  description = var.managed
  type        = "key_value"
}

resource "scaleway_secret" "argocd_oidc" {
  name        = "argocd-oidc"
  protected   = true
  description = var.managed
  type        = "key_value"
}

resource "scaleway_secret" "authentik" {
  name        = "authentik"
  protected   = true
  description = var.managed
  type        = "key_value"
}

# Django SECRET_KEY of the api-relay-cnav application, one per environment.
# Unlike the secrets above (shells whose versions are pushed manually), the value is generated here:
# ephemeral + write-only (data_wo), never stored in the tfstate (cf. emplois-cnav/database).
# The special-character pool is restricted to characters inert in URLs, shells and YAML.
ephemeral "random_password" "api_relay_cnav_django_secret_key" {
  for_each = var.api_relay_environments

  length           = 64
  override_special = "!*+-_"
}

resource "scaleway_secret" "api_relay_cnav_django" {
  for_each = var.api_relay_environments

  name        = "api-relay-django-${each.key}"
  protected   = true
  description = var.managed
  type        = "key_value"
}

# On rotation (version bump), the current key is re-read ephemerally (never through the state)
# and re-pushed as secret_key_fallbacks (Django SECRET_KEY_FALLBACKS): the values it signed
# (sessions...) stay verifiable for one more rotation cycle.
# Guarded on version 1: the secret has no version to read yet on the first push.
ephemeral "scaleway_secret_version" "api_relay_cnav_django_current" {
  for_each = { for env in var.api_relay_environments : env => env if var.django_secret_key_versions[env] > 1 }

  secret_id = scaleway_secret.api_relay_cnav_django[each.key].id
  revision  = "latest_enabled"
}

resource "scaleway_secret_version" "api_relay_cnav_django" {
  for_each = var.api_relay_environments

  secret_id = scaleway_secret.api_relay_cnav_django[each.key].id
  data_wo = jsonencode({
    secret_key = ephemeral.random_password.api_relay_cnav_django_secret_key[each.key].result
    secret_key_fallbacks = (
      var.django_secret_key_versions[each.key] > 1
      ? jsondecode(base64decode(ephemeral.scaleway_secret_version.api_relay_cnav_django_current[each.key].data)).secret_key
      : ""
    )
  })
  data_wo_version = var.django_secret_key_versions[each.key]
}

# PostgreSQL users' passwords of api-relay-cnav. The emplois-cnav/database module reads them back
# ephemerally to configure the RDB users: the user names below must stay in sync with it.
# Scaleway enforces complexity on RDB passwords (min. one digit, upper, lower and special
# character); the special-character pool is restricted to characters inert in URLs, shells and YAML.
ephemeral "random_password" "api_relay_cnav_db_jobs" {
  for_each = var.api_relay_environments

  length           = 32
  min_numeric      = 1
  min_upper        = 1
  min_lower        = 1
  min_special      = 1
  override_special = "!*+-_"
}

ephemeral "random_password" "api_relay_cnav_db_app" {
  for_each = var.api_relay_environments

  length           = 32
  min_numeric      = 1
  min_upper        = 1
  min_lower        = 1
  min_special      = 1
  override_special = "!*+-_"
}

resource "scaleway_secret" "api_relay_cnav_database" {
  for_each = var.api_relay_environments

  name        = "api-relay-database-${each.key}"
  protected   = true
  description = var.managed
  type        = "key_value"
}

resource "scaleway_secret_version" "api_relay_cnav_database" {
  for_each = var.api_relay_environments

  secret_id = scaleway_secret.api_relay_cnav_database[each.key].id
  data_wo = jsonencode({
    app_user      = "api_relay_cnav_${each.key}_app"
    app_password  = ephemeral.random_password.api_relay_cnav_db_app[each.key].result
    jobs_user     = "api_relay_cnav_${each.key}_jobs"
    jobs_password = ephemeral.random_password.api_relay_cnav_db_jobs[each.key].result
  })
  data_wo_version = var.database_credentials_versions[each.key]
}

# Connection endpoint of the shared PostgreSQL instance: only the shell is declared here:
# the content (host/port/name) is pushed by emplois-cnav/database
resource "scaleway_secret" "api_relay_cnav_database_connection" {
  for_each = var.api_relay_environments

  name        = "api-relay-database-connection-${each.key}"
  protected   = true
  description = var.managed
  type        = "key_value"
}
