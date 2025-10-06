terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_k8s_cluster" "cluster" {
  name                        = "emplois-cnav-cluster"
  description                 = var.managed
  version                     = "1.34"
  type                        = "kapsule"
  cni                         = "cilium"
  private_network_id          = data.scaleway_vpc_private_network.private_network.id
  delete_additional_resources = false
  feature_gates               = ["IPv6DualStack=false"]

  auto_upgrade {
    enable                        = true
    maintenance_window_day        = "monday"
    maintenance_window_start_hour = "04"
  }
}

resource "scaleway_k8s_pool" "default" {
  cluster_id  = scaleway_k8s_cluster.cluster.id
  name        = "default"
  node_type   = "DEV1-M"
  size        = 1
  autohealing = true
  autoscaling = false
  kubelet_args = {
    "feature-gates" = "IPv6DualStack=false"
  }
}
