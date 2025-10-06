terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_instance_security_group" "strongswan_security_group" {
  name        = "strongswan-security-group"
  description = var.managed
  stateful    = false
}

resource "scaleway_instance_server" "strongswan_instance" {
  name              = "strongswan-vpn"
  type              = "DEV1-S"
  image             = "debian_bookworm"
  security_group_id = scaleway_instance_security_group.strongswan_security_group.id

  root_volume {
    size_in_gb = 20
  }

  user_data = {
    cloud-init = <<-EOT
  #cloud-config
  ${yamlencode(local.instance_user_data)}
  EOT
  }
}

resource "scaleway_ipam_ip" "strongswan_instance_private_network_ip" {
  address = "10.251.9.1"

  source {
    private_network_id = data.scaleway_vpc_private_network.private_network.id
  }
}

resource "scaleway_instance_private_nic" "strongswan_instance_private_nic" {
  private_network_id = data.scaleway_vpc_private_network.private_network.id
  server_id          = scaleway_instance_server.strongswan_instance.id
  ipam_ip_ids        = [scaleway_ipam_ip.strongswan_instance_private_network_ip.id]
}
