variable "scw_region" {
  type        = string
  description = "Scaleway region for resources"
}

variable "scw_zone" {
  type        = string
  description = "Scaleway zone for resources"
}

variable "scw_project_id" {
  type        = string
  description = "Scaleway project_id for resources"
}

variable "records" {
  type = map(object({
    name     = string
    data     = string
    type     = string
    ttl      = optional(number, 3600)
    priority = optional(number, 0)
  }))
  description = "DNS records in the zone. The ID must be unique."
}
