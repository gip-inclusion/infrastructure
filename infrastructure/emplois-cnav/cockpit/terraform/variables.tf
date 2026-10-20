variable "scw_region" {
  type        = string
  description = "Scaleway region for resources"
}

variable "scw_zone" {
  type        = string
  description = "Scaleway zone for resources"
}

variable "kubernetes_logs_retention_days" {
  type        = number
  description = "Number of days the logs of the Kubernetes cluster are kept"
}
