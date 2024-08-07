#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

parse-config() {
  jq --raw-output '.[] | [.domains, .email, .plugin, .credentials, (.deployhook // "/etc/certbot/deploy-hooks/default.sh")] | join(" ")' $CERTBOT_CONFIG
}

certonly() {
  while read domains email plugin credentials deployhook; do
    echo "Creating for $domains ..."
    certbot \
      certonly \
      --agree-tos \
      --non-interactive \
      --$plugin \
      --$plugin-credentials $credentials \
      --$plugin-propagation-seconds 60 \
      --email $email \
      --deploy-hook $deployhook \
      --domains $domains
  done
}

echo "Config: $CERTBOT_CONFIG"
parse-config | certonly
