#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

parse-config() {
  jq --raw-output '.[] | [.domains, .email, .credentials, (.deployhook // "/etc/certbot/deploy-hooks/00-default.sh")] | join(" ")' $CERTBOT_CONFIG
}

certonly() {
  while read domains email credentials deployhook; do
    echo "Creating for $domains ..."
    certbot \
      certonly \
      --agree-tos \
      --non-interactive \
      --dns-cloudflare \
      --dns-cloudflare-credentials $credentials \
      --dns-cloudflare-propagation-seconds 60 \
      --email $email \
      --deploy-hook $deployhook \
      --domains $domains
  done
}

echo "Config: $CERTBOT_CONFIG"
parse-config | certonly
