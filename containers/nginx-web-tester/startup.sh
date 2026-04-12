#!/bin/sh

# Fetch metadata
VMHOSTNAME=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/hostname)

DNSRESOLUTION=$(cat /etc/resolv.conf)
PODHOSTNAME=$(cat /etc/hostname)
IPADDRESS=$(cat /etc/hosts)
Route=$(route)

# Export for envsubst
export VMHOSTNAME
export DNSRESOLUTION
export PODHOSTNAME
export IPADDRESS
export Route


# Replace variables in template → final HTML
envsubst < /usr/share/nginx/html/index.html.template \
         > /usr/share/nginx/html/index.html

# Start nginx
nginx -g "daemon off;"
