config setup
  charondebug="ike 2, knl 2, cfg 2, net 2"
  uniqueids=no

conn vpn-bcrs
  auto=start
  authby=psk
  type=tunnel
  keyexchange=ikev2
  ike=aes256-sha256-modp2048!
  esp=aes256gcm16-modp2048!
  left=%defaultroute
  leftauth=psk
  leftid=${public_gateway_ip.address}
  leftsubnet=${vpn_config.local_subnet}
  right=${vpn_config.remote_ip}
  rightauth=psk
  rightid=${vpn_config.remote_id}
  rightsubnet=${vpn_config.remote_subnet}
  dpdaction=restart
  dpddelay=30s
  dpdtimeout=120s
  lifetime=43200s
  ikelifetime=43200s
  keylife=3600s
