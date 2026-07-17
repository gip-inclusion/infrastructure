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

variable "api_relay_environments" {
  type        = set(string)
  description = "Environments getting the api-relay application secrets"
}

variable "django_secret_key_versions" {
  type        = map(number)
  description = "Per-environment Django SECRET_KEY version: bump it to rotate the key"

  validation {
    condition     = alltrue([for env in var.api_relay_environments : contains(keys(var.django_secret_key_versions), env)])
    error_message = "Each environment in api_relay_environments must have an entry in django_secret_key_versions."
  }
}

variable "database_credentials_versions" {
  type        = map(number)
  description = "Per-environment database credentials version: bump it to rotate the passwords, then apply emplois-cnav/database to propagate them to the RDB users"

  validation {
    condition     = alltrue([for env in var.api_relay_environments : contains(keys(var.database_credentials_versions), env)])
    error_message = "Each environment in api_relay_environments must have an entry in database_credentials_versions."
  }
}

variable "api_token_versions" {
  type        = map(number)
  description = "Per-environment API bearer token version: bump it to rotate the token (invalidates the previous token for API consumers)"

  validation {
    condition     = alltrue([for env in var.api_relay_environments : contains(keys(var.api_token_versions), env)])
    error_message = "Each environment in api_relay_environments must have an entry in api_token_versions."
  }
}
