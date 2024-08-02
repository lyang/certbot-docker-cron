#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

IFS=',' read -ra domains <<< "$DOMAINS"

for domain in "${domains[@]}"; do
  echo "Renewing for $domain ..."
  certbot \
    certonly \
    --non-interactive \
    --agree-tos \
    --email $EMAIL \
    --dns-cloudflare \
    --dns-cloudflare-credentials /opt/cloudflare/credentials \
    --domains $domain \
    --deploy-hook /usr/local/bin/deploy-hook.sh
done
