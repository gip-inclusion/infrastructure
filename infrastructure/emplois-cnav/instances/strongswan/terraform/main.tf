terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.60.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">= 1.4"
    }
  }
  required_version = ">= 1.10"
}

resource "scaleway_instance_security_group" "strongswan_security_group" {
  name                    = "strongswan-security-group"
  description             = var.managed
  stateful                = true
  inbound_default_policy  = "drop"
  outbound_default_policy = "drop"

  # Cloudflare DNS
  outbound_rule {
    action   = "accept"
    port     = 53
    protocol = "UDP"
    ip_range = "1.1.1.1/32"
  }

  outbound_rule {
    action   = "accept"
    port     = 53
    protocol = "UDP"
    ip_range = "1.0.0.1/32"
  }

  # Scaleway private DNS (VPC resource resolution)
  outbound_rule {
    action   = "accept"
    port     = 53
    protocol = "UDP"
    ip_range = "169.254.169.254/32"
  }

  # Debian repos via fixed-IP mirrors (overrides Fastly used by default).
  # See locals.tf write_files for the mirrorlist content.
  # Three mirrors are configured for failover.
  # All are officially listed at https://www.debian.org/mirror/list and serve both /debian/ and
  # /debian-security/.
  # Whitelist by /32 because each mirror has a single, stable A record.
  outbound_rule {
    action   = "accept"
    port     = 443
    protocol = "TCP"
    ip_range = "213.32.5.7/32" # debian.mirrors.ovh.net (OVH, France)
  }

  outbound_rule {
    action   = "accept"
    port     = 443
    protocol = "TCP"
    ip_range = "80.67.163.159/32" # mirror.gitoyen.net (Gitoyen, France)
  }

  outbound_rule {
    action   = "accept"
    port     = 443
    protocol = "TCP"
    ip_range = "129.132.89.152/32" # debian.ethz.ch (ETH Zurich, Swiss)
  }

  # Scaleway PPA on Launchpad (HTTP). Canonical's allocation is 185.125.188.0/22
  # Whitelist the full /22 because Launchpad uses anycast within this range and a /32 only matches one PoP
  outbound_rule {
    action   = "accept"
    port     = 80
    protocol = "TCP"
    ip_range = "185.125.188.0/22"
  }

  # IPSec from CNAV: IKE (key exchange) and NAT-T (NAT traversal), from primary and backup peers.
  inbound_rule {
    action   = "accept"
    port     = 500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_ip}/32"
  }

  inbound_rule {
    action   = "accept"
    port     = 500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_backup_ip}/32"
  }

  inbound_rule {
    action   = "accept"
    port     = 4500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_ip}/32"
  }

  inbound_rule {
    action   = "accept"
    port     = 4500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_backup_ip}/32"
  }

  # Traffic from Private Network (K8s pods)
  inbound_rule {
    action   = "accept"
    protocol = "ANY"
    ip_range = one(data.scaleway_vpc_private_network.strongswan_private_network.ipv4_subnet).subnet
  }

  # IPSec to CNAV: IKE and NAT-T, to primary and backup peers
  outbound_rule {
    action   = "accept"
    port     = 500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_ip}/32"
  }

  outbound_rule {
    action   = "accept"
    port     = 500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_backup_ip}/32"
  }

  outbound_rule {
    action   = "accept"
    port     = 4500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_ip}/32"
  }

  outbound_rule {
    action   = "accept"
    port     = 4500
    protocol = "UDP"
    ip_range = "${local.vpn_config.remote_backup_ip}/32"
  }

  # Traffic to Private Network (K8s pods)
  outbound_rule {
    action   = "accept"
    protocol = "ANY"
    ip_range = one(data.scaleway_vpc_private_network.strongswan_private_network.ipv4_subnet).subnet
  }
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
  address = local.strongswan_management_ip

  source {
    private_network_id = data.scaleway_vpc_private_network.strongswan_private_network.id
  }
}

resource "scaleway_ipam_ip" "interops_integration_ip" {
  address = local.vpn_config.local_ip_integration

  source {
    private_network_id = data.scaleway_vpc_private_network.strongswan_private_network.id
  }
}

resource "scaleway_ipam_ip" "interops_production_ip" {
  address = local.vpn_config.local_ip_production

  source {
    private_network_id = data.scaleway_vpc_private_network.strongswan_private_network.id
  }
}

resource "scaleway_instance_private_nic" "strongswan_instance_private_nic" {
  private_network_id = data.scaleway_vpc_private_network.strongswan_private_network.id
  server_id          = scaleway_instance_server.strongswan_instance.id

  # All three IPs are attached at the VPC layer so Scaleway can route packets destined to any of them to
  # this NIC. Scaleway DHCP only leases one of them per attachment though, and which one it picks
  # is not deterministic (the `strongswan-extra-ips` systemd unit re-applies all three idempotently on every boot).
  ipam_ip_ids = [
    scaleway_ipam_ip.strongswan_instance_private_network_ip.id,
    scaleway_ipam_ip.interops_integration_ip.id,
    scaleway_ipam_ip.interops_production_ip.id,
  ]
}

resource "scaleway_vpc_public_gateway_pat_rule" "ipsec_ike" {
  gateway_id   = data.scaleway_vpc_public_gateway.strongswan_public_gateway.id
  private_ip   = scaleway_ipam_ip.strongswan_instance_private_network_ip.address
  private_port = 500
  public_port  = 500
  protocol     = "udp"
}

resource "scaleway_vpc_public_gateway_pat_rule" "ipsec_nat_t" {
  gateway_id   = data.scaleway_vpc_public_gateway.strongswan_public_gateway.id
  private_ip   = scaleway_ipam_ip.strongswan_instance_private_network_ip.address
  private_port = 4500
  public_port  = 4500
  protocol     = "udp"
}
