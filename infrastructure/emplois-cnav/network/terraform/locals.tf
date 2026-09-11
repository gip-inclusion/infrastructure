locals {
  strongswan_private_network_subnet            = yamldecode(data.sops_file.secrets.raw)["strongswan_private_network_subnet"]
  strongswan_private_network_public_gateway_ip = yamldecode(data.sops_file.secrets.raw)["strongswan_private_network_public_gateway_ip"]
  kubernetes_private_network_subnet            = yamldecode(data.sops_file.secrets.raw)["kubernetes_private_network_subnet"]
  kubernetes_private_network_public_gateway_ip = yamldecode(data.sops_file.secrets.raw)["kubernetes_private_network_public_gateway_ip"]
}
