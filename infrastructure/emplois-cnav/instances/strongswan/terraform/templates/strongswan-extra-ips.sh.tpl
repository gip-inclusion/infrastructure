#!/bin/bash
# Configure all three IPs on the private network interface at every boot.
# The interop IPs are the SNAT exit points for K8s pods reaching CNAV (Scaleway Kapsule does not expose
# Cilium Egress Gateway, so this VM acts as a NAT gateway). The management IP is the target of the Public
# Gateway PAT rules forwarding IPsec UDP 500/4500 to this VM.
# All three are reserved in IPAM and attached to the NIC via `ipam_ip_ids`, but Scaleway's Private Network
# DHCP leases only one address per attachment (verified from /run/systemd/netif/leases/X : single ADDRESS
# field) and which one it picks is not deterministic. So we replace all three here unconditionally at boot:
# whichever one DHCP already configured is a no-op, the other two are applied.
set -eu

# Wait up to 30s for the primary private network IP to be configured by DHCP
PN_IFACE=""
for _ in $(seq 1 30); do
  PN_IFACE=$(ip -4 addr show | awk '/inet ${private_network_prefix}\./ {print $NF; exit}')
  [ -n "$PN_IFACE" ] && break
  sleep 1
done

if [ -z "$PN_IFACE" ]; then
  echo "No private network interface found" >&2
  exit 1
fi

# `ip addr replace` makes this idempotent.
ip addr replace ${strongswan_management_ip}/32 dev "$PN_IFACE"
ip addr replace ${local_ip_integration}/32 dev "$PN_IFACE"
ip addr replace ${local_ip_production}/32 dev "$PN_IFACE"
