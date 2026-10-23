terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.69.0"
    }
  }
  required_version = ">= 1.11"
}

# Logs of the Kubernetes cluster pods, pushed by the collector deployed from emplois-cnav-ops
# The push token is not managed here (avoiding storage in the state)
resource "scaleway_cockpit_source" "kubernetes_logs" {
  name           = "Kubernetes Logs"
  type           = "logs"
  retention_days = var.kubernetes_logs_retention_days
}
