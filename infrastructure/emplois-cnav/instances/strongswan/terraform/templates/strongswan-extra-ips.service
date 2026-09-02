[Unit]
Description=Add CNAV InterOPS secondary IPs to private NIC
After=network-online.target
Wants=network-online.target
# Scaleway attaches the private NIC asynchronously after the VM has started, so the script may run before
# DHCP has configured the interface.
# Allow up to 20 retries over 10 minutes (RestartSec=10s) before giving up.
StartLimitIntervalSec=600
StartLimitBurst=20

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/strongswan-extra-ips.sh
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
