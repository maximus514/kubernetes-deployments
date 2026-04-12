#!/bin/sh

# Fetch metadata
HOSTNAME=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/hostname)

# Export for envsubst
export HOSTNAME

# Replace variables in template → final HTML
envsubst < /usr/share/nginx/html/index.html.template \
         > /usr/share/nginx/html/index.html

# Start nginx
nginx -g "daemon off;"
