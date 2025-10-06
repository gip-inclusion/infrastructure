locals {
  strongswan_public_gateway_ip = {
    id = "fr-par-1/e54df15d-fdbf-40bb-bc04-0957a450a65b" # FIXME: This should be dynamically fetched. SW Ticket 1518441
  }
  vpn_config = jsondecode(base64decode(data.scaleway_secret_version.cnav_vpn_config.data))
  # ipsec_conf_content = templatefile("${path.module}/templates/ipsec.conf.tpl", {
  #   public_gateway_ip   = data.scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip.address
  #   vpn_config = local.vpn_config
  # })
  # ipsec_secrets_content = templatefile("${path.module}/templates/ipsec.secrets.tpl", {
  #   vpn_config = local.vpn_config
  # })
  instance_user_data = {
    packages = [
      "strongswan",
      "iptables"
    ]
    write_files = [
      {
        path = "/etc/ipsec.conf"
        content = base64encode(
          templatefile("${path.module}/templates/ipsec.conf.tpl", {
            public_gateway_ip = data.scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip
            vpn_config        = local.vpn_config
          })
        )
        encoding = "b64"
      },
      {
        path = "/etc/ipsec.secrets"
        content = base64encode(
          templatefile("${path.module}/templates/ipsec.secrets.tpl", {
            public_gateway_ip = data.scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip
            vpn_config        = local.vpn_config
          })
        )
        encoding = "b64"
      },
    ]
    runcmd = [
      "sysctl -w net.ipv4.ip_forward=1",
      "iptables -t nat -A POSTROUTING -s ${local.vpn_config.local_subnet} -o ens5 -j SNAT --to-source ${data.scaleway_vpc_public_gateway_ip.strongswan_public_gateway_ip.address}",
      "systemctl enable strongswan-starter",
      "systemctl restart strongswan-starter"
    ]
  }
}
