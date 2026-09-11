connections {
  vpn-bcrs {
    # Allow multiple IKE_SAs sharing the same peer ID to coexist (prevents races
    # during rekey where the new SA would prematurely kill the live one) - default value
    unique = no

    # Use IKEv2 (as required by CNAV peers)
    version=2

    # IKE (phase 1) suite required by CNAV: AES-256-CBC / SHA-256 / DH group 14.
    proposals=aes256-sha256-modp2048

    # IKE_SA lifetime (12h) — a rekey (not a reauth, see below) happens at this point
    rekey_time=43200s

    # Use IKEv2 rekey instead of full reauth: avoids "no CHILD_SA to recreate" failure
    # that left the tunnel down with no retry every ~12h
    # catches a silently-dead peer fast (paired with dpdaction=restart above)
    reauth_time=0s

    # Never give up retrying a failed negotiation
    keyingtries=0

    # PDI side. Use %any rather than a hardcoded IP, so we let charon pick the correct
    # source during negociation
    local_addrs=%any

    # CNAV public endpoint on which we initiate the tunnel
    remote_addrs=${vpn_config.remote_ip}

    # Short interval to keep the tunnel established: warms the NAT-T binding and
    # catches a silently-dead peer fast (paired with dpdaction=start below)
    dpd_delay=30s
    # Declare the peer dead if no DPD response within 120s
    dpd_timeout=120s

    children {
      vpn-bcrs {
        # Bring the tunnel up at boot without waiting for traffic to trigger it
        start_action=start
        # Site-to-site tunnel mode (encapsulate full IP packets) - default value
        mode=tunnel

        # ESP (phase 2) suite required by CNAV: AES-256-GCM (AEAD) + DH group 14 for PFS
        esp_proposals=aes256gcm16-modp2048

        # Child_SA (ESP) lifetime (1h) — ESP keys rotate hourly for forward secrecy
        rekey_time=3600s

        # Re-establish the tunnel if the peer sends a DELETE (ex: CNAV-side reset)
        close_action=start

        # PDI subnet announced into the tunnel (traffic selector)
        local_ts=${vpn_config.local_subnet}

        # CNAV subnet reachable through the tunnel (traffic selector)
        remote_ts=${vpn_config.remote_subnet}

        # On Dead Peer Detection failure, tear down and restart the connection
        dpd_action=start
      }
    }

    local-0 {
      # PDI authentication method
      auth = psk
      # PDI identity sent to CNAV (their firewall whitelists this exact IP)
      id = ${public_gateway_ip.address}
    }
    remote-0 {
      # CNAV authentication method
      auth = psk
      # Expected CNAV identity (according to the network convention, must match exactly)
      id = ${vpn_config.remote_id}
    }

  }
}
pools {
}
authorities {
}
secrets {
  ike-public-gateway {
    secret = "<SET_THE_PSK_HERE>"
    id-0=${public_gateway_ip.address}
  }
  ike-remote-ip {
    secret = "<SET_THE_PSK_HERE>"
    id-0=${vpn_config.remote_ip}
  }
  ike-remote-backup-ip {
    secret = "<SET_THE_PSK_HERE>"
    id-0=${vpn_config.remote_backup_ip}
  }
}
