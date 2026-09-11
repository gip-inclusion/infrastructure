terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.69.0"
    }
  }
  # Write-only arguments (password_wo) require Terraform 1.11
  required_version = ">= 1.11"
}

# Single managed PostgreSQL instance shared by both environments, mirroring the
# shared Kubernetes cluster: one database and one pair of users per environment.
# Only reachable through the Kubernetes Private Network: attaching a private_network
# without declaring a load_balancer block means no public endpoint at all.
# https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_instance#load_balancer-1
resource "scaleway_rdb_instance" "postgresql" {
  name               = "emplois-cnav-postgresql"
  engine             = var.database_engine
  node_type          = var.database_node_type
  is_ha_cluster      = var.database_is_ha_cluster
  encryption_at_rest = true
  volume_type        = "sbs_5k"
  volume_size_in_gb  = var.database_volume_size_in_gb

  backup_schedule_frequency = 24
  backup_schedule_retention = var.database_backup_schedule_retention
  # Keep any manual logical backup in fr-par region (any AZ)
  # Scaleway stores them in another region by default
  backup_same_region = true

  private_network {
    pn_id       = data.scaleway_vpc_private_network.kubernetes_private_network.id
    enable_ipam = true
  }

  lifecycle {
    # Defensive: fail any plan/apply where Scaleway would expose a public (load balancer) endpoint
    # Ex: after a provider or API behavior change...
    postcondition {
      condition     = length(self.load_balancer) == 0
      error_message = "The shared PostgreSQL instance must never expose a public endpoint."
    }
  }
}

# Declare a database for each environment
resource "scaleway_rdb_database" "api_relay_cnav" {
  for_each = var.database_environments

  instance_id = scaleway_rdb_instance.postgresql.id
  name        = "api_relay_cnav_${each.key}"
}

# The users' passwords are generated and stored in the secret-manager module and read back ephemerally here
# to configure the RDB users (they are never stored in the state).
# password_wo_version derives from the secret's version_count: applying this module  after a rotation
# in secret-manager re-pushes the new passwords to the users.
ephemeral "scaleway_secret_version" "api_relay_cnav_database" {
  for_each = var.database_environments

  secret_id = data.scaleway_secret.api_relay_cnav_database[each.key].id
  revision  = "latest_enabled"
}

# DDL + DML user: used by the jobs (Django migrations / management commands)
resource "scaleway_rdb_user" "api_relay_cnav_jobs" {
  for_each = var.database_environments

  instance_id         = scaleway_rdb_instance.postgresql.id
  name                = "api_relay_cnav_${each.key}_jobs"
  password_wo         = jsondecode(base64decode(ephemeral.scaleway_secret_version.api_relay_cnav_database[each.key].data)).jobs_password
  password_wo_version = data.scaleway_secret.api_relay_cnav_database[each.key].version_count
  is_admin            = false
}

resource "scaleway_rdb_privilege" "api_relay_cnav_jobs" {
  for_each = var.database_environments

  instance_id   = scaleway_rdb_instance.postgresql.id
  user_name     = scaleway_rdb_user.api_relay_cnav_jobs[each.key].name
  database_name = scaleway_rdb_database.api_relay_cnav[each.key].name
  permission    = "all"
}

# DML-only user: used by the pods serving traffic
# Each environment's user only gets privileges on its own database (none on the other one).
# Note: Scaleway applies "readwrite" to the objects existing at apply time only, so this privilege
# is just the baseline: the migration job re-grants DML (and sets default privileges)
# on the tables it creates (see `manage.py grant_app_privileges` in api-relay-cnav).
# The API may thus report this privilege as drifted ("custom"); re-applying it is harmless.
# https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/rdb_privilege#permission-drift-management
resource "scaleway_rdb_user" "api_relay_cnav_app" {
  for_each = var.database_environments

  instance_id         = scaleway_rdb_instance.postgresql.id
  name                = "api_relay_cnav_${each.key}_app"
  password_wo         = jsondecode(base64decode(ephemeral.scaleway_secret_version.api_relay_cnav_database[each.key].data)).app_password
  password_wo_version = data.scaleway_secret.api_relay_cnav_database[each.key].version_count
  is_admin            = false
}

resource "scaleway_rdb_privilege" "api_relay_cnav_app" {
  for_each = var.database_environments

  instance_id   = scaleway_rdb_instance.postgresql.id
  user_name     = scaleway_rdb_user.api_relay_cnav_app[each.key].name
  database_name = scaleway_rdb_database.api_relay_cnav[each.key].name
  permission    = "readwrite"
}

# Connection endpoint handed to the cluster through Secret Manager (shell declared in secret-manager)
# The External Secrets Operator syncs it into the interops-* namespaces
# Not sensitive (private IP), hence a regular version: any content change
# (ex: new endpoint after an instance re-creation) pushes a new version on apply
resource "scaleway_secret_version" "api_relay_cnav_database_connection" {
  for_each = var.database_environments

  secret_id = data.scaleway_secret.api_relay_cnav_database_connection[each.key].id
  data = jsonencode({
    host = scaleway_rdb_instance.postgresql.private_network[0].ip
    port = tostring(scaleway_rdb_instance.postgresql.private_network[0].port)
    name = scaleway_rdb_database.api_relay_cnav[each.key].name
  })
}
