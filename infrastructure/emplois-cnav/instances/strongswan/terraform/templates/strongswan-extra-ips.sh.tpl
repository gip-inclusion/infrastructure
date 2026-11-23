#!/bin/bash
# Configure all three IPs on the private network interface at every boot.
# The interop IPs are the SNAT exit points for K8s pods reaching CNAV (Scaleway Kapsule does not expose
# Cilium Egress Gateway, so this VM acts as a NAT gateway). The management IP is the target of the Public
# Gateway PAT rules forwarding IPsec UDP 500/4500 to this VM.
# All three are reserved in IPAM and attached to the NIC via `ipam_ip_ids`, but Scaleway's Private Network
# DHCP leases only one address per attachment (verified from /run/systemd/netif/leases/X : single ADDRESS
# field) and which one it picks is not deterministic. So we add the other two here at boot, skipping the one DHCP
# already configured: a duplicate /32 of the DHCP address makes systemd-networkd remove the DHCP /20 instead when it
# purges foreign addresses, leaving the VM without its DHCP routes.
#
# FIXME: `netplan apply` in scw-vpc-iface, occurring a few seconds later in the boot, removes the IPs added here
# (Scaleway support #1637835). Things still work: NAT does not need the interop IPs to be local (DNAT happens before
# routing, SNAT sets them explicitly), and the management IP, the only one that must be local, has been the DHCP one
# on every boot of this instance so far. If DHCP ever leases another one, this script adds the management IP as a
# /32, but that `netplan apply` removes it a few seconds later and IPsec breaks.
# So far, has not occurred with Trixie since september. Awaiting Scaleway's answer to harden that...

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

for ip in ${strongswan_management_ip} ${local_ip_integration} ${local_ip_production}; do
  ip -4 addr show dev "$PN_IFACE" | grep -qF "inet $ip/" || ip addr replace "$ip/32" dev "$PN_IFACE"
done
