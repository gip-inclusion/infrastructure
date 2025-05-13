variable "managed" {
  type        = string
  description = "Indicates the resource is managed by Terraform"
}

variable "organization_id" {
  type        = string
  description = "ID of the Scaleway org"
}

variable "records" {
  type = map(object({
    name     = string
    data     = string
    type     = string
    ttl      = optional(number, 3600)
    priority = optional(number, 0)
  }))
  description = "DNS records in the zone. The id must be unique."
}
