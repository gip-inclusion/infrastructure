variable "scw_region" {
  type        = string
  description = "Scaleway region for resources"
}

variable "scw_zone" {
  type        = string
  description = "Scaleway zone for resources"
}

variable "managed" {
  type        = string
  description = "Indicates the resource is managed by Terraform"
  default     = "Managed by Terraform"
}

variable "database_engine" {
  type        = string
  description = "Managed PostgreSQL engine version (see `scw rdb engine list`)"
}

variable "database_node_type" {
  type        = string
  description = "Node type of the managed PostgreSQL instance"
}

variable "database_is_ha_cluster" {
  type        = bool
  description = "Enable high availability on the managed PostgreSQL instance"
}

variable "database_volume_size_in_gb" {
  type        = number
  description = "Block storage size of the managed PostgreSQL instance"
}

variable "database_backup_schedule_retention" {
  type        = number
  description = "Automated backups retention, in days"
}

variable "database_environments" {
  type        = set(string)
  description = "Environments getting a database and its pair of users on the shared instance"
}
