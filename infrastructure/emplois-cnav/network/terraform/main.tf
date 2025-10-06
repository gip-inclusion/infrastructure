terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.57"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_vpc" "vpc" {
  name = "emplois-cnav-vpc"
}

resource "scaleway_vpc_private_network" "private_network" {
  name                             = "emplois-cnav-vpc-private-network"
  vpc_id                           = scaleway_vpc.vpc.id
  enable_default_route_propagation = true

  ipv4_subnet {
    subnet = "10.251.0.0/20"
  }
}

resource "scaleway_vpc_public_gateway_ip" "strongswan_public_gateway_ip" {
  tags = ["emplois-cnav-strongswan-public-gateway-ip"] # Required for filtering in data sources
}

resource "scaleway_vpc_public_gateway" "strongswan_public_gateway" {
  name            = "strongswan-public-gateway"
  type            = "VPC-GW-S"
  ip_id           = scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip.id
  bastion_enabled = true
  bastion_port    = 61000
}

resource "scaleway_ipam_ip" "strongswan_public_gateway_private_network_ip" {
  address = "10.251.1.1"

  source {
    private_network_id = scaleway_vpc_private_network.private_network.id
  }
}

resource "scaleway_vpc_gateway_network" "strongswan_gateway_network" {
  gateway_id         = scaleway_vpc_public_gateway.strongswan_public_gateway.id
  private_network_id = scaleway_vpc_private_network.private_network.id

  ipam_config {
    push_default_route = true
    ipam_ip_id         = scaleway_ipam_ip.strongswan_public_gateway_private_network_ip.id
  }
}
