#!/bin/bash

(
  # Configure tunnel protocol if specified
  if [[ "$TUNNEL_PROTOCOL" == "MASQUE" ]]; then
    cat <<EOF >/var/lib/cloudflare-warp/mdm.xml
<dict>
    <key>warp_tunnel_protocol</key>
    <string>masque</string>
</dict>
EOF
  else
    rm -rf /var/lib/cloudflare-warp/mdm.xml
  fi

  sleep 5

  # Check if warp-svc is running before proceeding
  until warp-cli --accept-tos registration new; do
    sleep 1
    echo >&2 "Waiting for warp-svc to start..."
  done

  # Configure WARP proxy mode and proxy port
  warp-cli --accept-tos mode proxy
  warp-cli --accept-tos proxy port 40000
  warp-cli --accept-tos dns log disable

  # Set families mode if provided
  if [[ -n "$FAMILIES_MODE" ]]; then
    warp-cli --accept-tos dns families "${FAMILIES_MODE}"
  fi

  # Set license key if provided
  if [[ -n "$WARP_LICENSE" ]]; then
    warp-cli --accept-tos registration license "${WARP_LICENSE}"
  fi

  # Connect to WARP
  warp-cli --accept-tos connect

  # Forward traffic from port 1080 to 40000 using socat for SOCKS5 proxy
  socat tcp-listen:1080,reuseaddr,fork tcp:127.0.0.1:40000
) &

# Start the warp service and enable always-on mode
exec warp-svc | grep -v DEBUG
warp-cli enable-always-on
