variable "scw_default_region" {
  type        = string
  description = "Default Scaleway region for resources"
}

variable "scw_default_zone" {
  type        = string
  description = "Default Scaleway zone for resources"
}

variable "scw_organization_id" {
  type        = string
  description = "ID of the Scaleway organization"
}

variable "managed" {
  type        = string
  description = "Indicates the resource is managed by Terraform"
  default     = "Managed by Terraform"
}
