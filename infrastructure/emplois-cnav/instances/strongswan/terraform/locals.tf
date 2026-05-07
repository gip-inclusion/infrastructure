locals {
  strongswan_public_gateway_ip = {
    id = "fr-par-1/e54df15d-fdbf-40bb-bc04-0957a450a65b" # FIXME: This should be dynamically fetched. SW Ticket 1518441
  }
  vpn_config                        = jsondecode(base64decode(data.scaleway_secret_version.cnav_vpn_config.data))
  strongswan_management_ip          = yamldecode(data.sops_file.secrets.raw)["strongswan_management_ip"]
  private_network_subnet            = one(data.scaleway_vpc_private_network.strongswan_private_network.ipv4_subnet).subnet
  kubernetes_private_network_subnet = one(data.scaleway_vpc_private_network.kubernetes_private_network.ipv4_subnet).subnet
  # First two octets of the private network subnet, used as a regex anchor in interface detection
  # (e.g. "10.42" derived from "10.42.0.0/20"). Suitable for /16-/24 prefixes.
  private_network_prefix = join(".", slice(split(".", split("/", local.private_network_subnet)[0]), 0, 2))

  instance_user_data = {
    manage_resolv_conf = true
    resolv_conf = {
      nameservers = [
        "1.1.1.1",         # CF DNS
        "1.0.0.1",         # CF DNS
        "169.254.169.254", # Scaleway private DNS
      ]
    }
    # Note: no `packages` directive. cloud-init's apt-configure runs in the cloud-config phase and overwrites
    # our mirrorlist with the default Fastly URI from /etc/cloud/cloud.cfg.d/, which our security group blocks.
    # Package install is performed in runcmd, after the mirrorlists have been rewritten to set the 3 whitelisted ones.
    write_files = [
      # Strongswan IPsec connection config: peer IDs, tunnel parameters, traffic selectors.
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
      # Strongswan PSK file. The PSK is left as a placeholder and must be set manually on the VM post-deploy
      # (this keeps the secret out of Terraform state).
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
      # Script that adds the management + two InterOPS source IPs to the private NIC at every boot.
      # Run by the systemd unit below. Full rationale in the template file.
      {
        path = "/usr/local/sbin/strongswan-extra-ips.sh"
        content = base64encode(
          templatefile("${path.module}/templates/strongswan-extra-ips.sh.tpl", {
            strongswan_management_ip = local.strongswan_management_ip
            local_ip_integration     = local.vpn_config.local_ip_integration
            local_ip_production      = local.vpn_config.local_ip_production
            private_network_prefix   = local.private_network_prefix
          })
        )
        encoding    = "b64"
        permissions = "0755"
      },
      # Systemd unit that runs the script above at every boot.
      {
        path = "/etc/systemd/system/strongswan-extra-ips.service"
        content = base64encode(
          templatefile("${path.module}/templates/strongswan-extra-ips.service.tpl", {})
        )
        encoding = "b64"
      },
      # All dpkg installs will keep the existing conffiles when the package ships an updated default.
      # Strongswan config files are generated (/etc/ipsec.conf above) via cloud-init before the package is installed,
      # and we do not want strongswan/security-update upgrades to hang silently on the conffile prompt or to mess up
      # the config. Applies system-wide, including to unattended-upgrades.
      {
        path = "/etc/apt/apt.conf.d/99-noninteractive"
        content = base64encode(<<-EOT
        Dpkg::Options { "--force-confdef"; "--force-confold"; };
        EOT
        )
        encoding = "b64"
      },
    ]
    runcmd = [
      # =============================================================================
      # Wait for the private NIC to be configured before doing anything requiring networking.
      # On this Scaleway cloud image, the public NIC only has an IPv6 link-local address, the only IPv4 default route
      # goes via the private NIC to the Public Gateway, so apt would fail until the private NIC has its IP.
      # Performed here in runcmd (cloud-final phase) and not in bootcmd (cloud-init phase) because
      # scw-vpc-iface@<dev>.service only configures the NIC after cloud-init.service is done (otherwise, deadlock).
      # Capped at 5 minutes, if the private NIC is never attached, the apt commands below will fail.
      # =============================================================================
      "for i in $(seq 1 300); do ip -4 addr show | grep -q 'inet ${local.private_network_prefix}\\.' && break; sleep 1; done",

      # =============================================================================
      # Make all subsequent commands in this runcmd non-interactive for any prompts that might pop up during install.
      # Cloud-init does not export this for runcmd scripts.
      # =============================================================================
      "export DEBIAN_FRONTEND=noninteractive",

      # =============================================================================
      # Kernel: enable IP forwarding (needed for routing between pods and VPN)
      # =============================================================================
      "sysctl -w net.ipv4.ip_forward=1",
      "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf",

      # =============================================================================
      # APT: replace cloud-init's default mirrorlist (single Fastly URL, blocked by the security group)
      # with our 3 whitelisted mirrors.
      # Apt's mechanism then tries each URL in order until one responds.
      # The packages install runs here too so it uses our mirrors, not the default Fastly.
      # =============================================================================
      "echo 'https://debian.mirrors.ovh.net/debian/'  > /etc/apt/mirrors/debian.list",
      "echo 'https://mirror.gitoyen.net/debian/'     >> /etc/apt/mirrors/debian.list",
      "echo 'https://debian.ethz.ch/debian/'         >> /etc/apt/mirrors/debian.list",
      "echo 'https://debian.mirrors.ovh.net/debian-security/'  > /etc/apt/mirrors/debian-security.list",
      "echo 'https://mirror.gitoyen.net/debian-security/'     >> /etc/apt/mirrors/debian-security.list",
      "echo 'https://debian.ethz.ch/debian-security/'         >> /etc/apt/mirrors/debian-security.list",
      "apt update",
      "apt install -y strongswan iptables iptables-persistent",

      # =============================================================================
      # Network: enable the systemd unit that applies secondary IPs to the private NIC at every boot
      # (see /usr/local/sbin/strongswan-extra-ips.sh)
      # =============================================================================
      "systemctl daemon-reload",
      "systemctl enable --now strongswan-extra-ips.service",

      # =============================================================================
      # Firewall: base rules (stateful tracking + loopback)
      # =============================================================================
      "iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT",
      "iptables -A INPUT  -i lo -j ACCEPT",
      "iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT",
      "iptables -A OUTPUT -o lo -j ACCEPT",

      # =============================================================================
      # Firewall: ingress (IPsec only, from CNAV peers)
      # =============================================================================
      # IPsec from CNAV peers
      "iptables -A INPUT -p udp --dport 500  -s ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A INPUT -p udp --dport 4500 -s ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A INPUT -p udp --dport 500  -s ${local.vpn_config.remote_backup_ip} -j ACCEPT",
      "iptables -A INPUT -p udp --dport 4500 -s ${local.vpn_config.remote_backup_ip} -j ACCEPT",

      # Scaleway private network (between VMs / cluster nodes)
      "iptables -A INPUT -s ${local.private_network_subnet} -j ACCEPT",

      # =============================================================================
      # Firewall: egress (system updates, DNS, IPsec, CNAV)
      # =============================================================================
      # System updates, DNS and VPC traffic
      "iptables -A OUTPUT -p udp --dport 53 -d 1.1.1.1 -j ACCEPT",              # Cloudflare DNS
      "iptables -A OUTPUT -p udp --dport 53 -d 1.0.0.1 -j ACCEPT",              # Cloudflare DNS (secondary)
      "iptables -A OUTPUT -p tcp --dport 80 -d 169.254.42.42 -j ACCEPT",        # Scaleway Metadata API
      "iptables -A OUTPUT -p udp --dport 67 -d 169.254.169.254 -j ACCEPT",      # Scaleway VPC DHCP
      "iptables -A OUTPUT -p udp --dport 53 -d 169.254.169.254 -j ACCEPT",      # Scaleway VPC DNS
      "iptables -A OUTPUT -p udp --dport 123 -d 169.254.169.254 -j ACCEPT",     # Scaleway VPC NTP
      "iptables -A OUTPUT -p tcp --dport 443 -d 213.32.5.7/32       -j ACCEPT", # debian.mirrors.ovh.net
      "iptables -A OUTPUT -p tcp --dport 443 -d 80.67.163.159/32    -j ACCEPT", # mirror.gitoyen.net
      "iptables -A OUTPUT -p tcp --dport 443 -d 129.132.89.152/32   -j ACCEPT", # debian.ethz.ch (fallback)
      "iptables -A OUTPUT -p tcp --dport 80  -d 185.125.188.0/22    -j ACCEPT", # Canonical Launchpad (Scaleway PPA)

      # IPsec to CNAV peers
      "iptables -A OUTPUT -p udp --dport 500  -d ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A OUTPUT -p udp --dport 4500 -d ${local.vpn_config.remote_ip} -j ACCEPT",
      "iptables -A OUTPUT -p udp --dport 500  -d ${local.vpn_config.remote_backup_ip} -j ACCEPT",
      "iptables -A OUTPUT -p udp --dport 4500 -d ${local.vpn_config.remote_backup_ip} -j ACCEPT",

      # Scaleway private network (between VMs / cluster nodes)
      "iptables -A OUTPUT -d ${local.private_network_subnet} -j ACCEPT",

      # Allow HTTPS to CNAV subnet for local debugging (curl/openssl from this VM).
      # Production traffic from K8s pods uses FORWARD chain via DNAT, not OUTPUT.
      "iptables -A OUTPUT -d ${local.vpn_config.remote_subnet} -p tcp --dport 443 -j ACCEPT",

      # =============================================================================
      # Firewall: NAT rules for K8s pods → CNAV via VPN tunnel
      # Pods have IPs in Cilium CIDR. The IPsec tunnel only accepts traffic
      # from leftsubnet. We use DNAT+SNAT:
      #   1. DNAT redirects pod traffic (destined to local_ip_*) to actual CNAV IP
      #   2. SNAT changes source IP to match IPsec tunnel selector
      # Conntrack handles return traffic transparently.
      #
      # Flow: Pod -> strongswan (local_ip_*) -> DNAT -> SNAT -> tunnel -> CNAV
      # =============================================================================
      # DNAT: Redirect traffic destined to strongswan IPs to actual CNAV endpoints
      "iptables -t nat -A PREROUTING  -s ${local.kubernetes_private_network_subnet} -d ${local.vpn_config.local_ip_integration} -j DNAT --to-destination ${local.vpn_config.remote_ip_integration}",
      "iptables -t nat -A PREROUTING  -s ${local.kubernetes_private_network_subnet} -d ${local.vpn_config.local_ip_production}  -j DNAT --to-destination ${local.vpn_config.remote_ip_production}",

      # SNAT: Change source IP so traffic matches IPsec tunnel selectors (leftsubnet)
      # We use conntrack to remember the original destination (before DNAT) and apply the matching source IP
      # This ensures integration pods exit with integration IP, production pods with production IP
      # Conntrack also handles return traffic (CNAV responses): it remembers the original pod IP
      # and automatically reverses the NAT to route responses back to the correct pod
      "iptables -t nat -A POSTROUTING -m conntrack --ctorigdst ${local.vpn_config.local_ip_integration} -j SNAT --to-source ${local.vpn_config.local_ip_integration}",
      "iptables -t nat -A POSTROUTING -m conntrack --ctorigdst ${local.vpn_config.local_ip_production}  -j SNAT --to-source ${local.vpn_config.local_ip_production}",

      # =============================================================================
      # Firewall: log and drop
      # Rate-limited LOG before DROP for observability without flooding journals
      # =============================================================================
      "iptables -A INPUT  -m limit --limit 10/min -j LOG --log-prefix 'DROP-IN: '  --log-level 4",
      "iptables -A OUTPUT -m limit --limit 10/min -j LOG --log-prefix 'DROP-OUT: ' --log-level 4",
      "iptables -A INPUT  -j DROP",
      "iptables -A OUTPUT -j DROP",

      # =============================================================================
      # Persist iptables rules
      # =============================================================================
      "netfilter-persistent save",

      # =============================================================================
      # Start strongswan
      # =============================================================================
      "systemctl enable strongswan-starter",
      "systemctl restart strongswan-starter",
    ]
  }
}
