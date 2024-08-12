#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

parse-config() {
  local fields=(
    '.domains'
    '.email'
    '.plugin'
    '.credentials'
    '(."hook_type" // "deploy")'
    '(."hook_script" // "/etc/certbot/deploy-hooks/default.sh")'
  )
  local filter=$(join-array , "${fields[@]}")
  jq --raw-output ".[] | [$filter] | join(\" \")" $CERTBOT_CONFIG
}

join-array() {
  local IFS="$1"
  shift
  echo "$*"
}

certonly() {
  local domains email plugin credentials hook_type hook_script
  while read domains email plugin credentials hook_type hook_script; do
    echo "Creating for $domains ..."
    certbot \
      certonly \
      --agree-tos \
      --non-interactive \
      --$plugin \
      --$plugin-credentials $credentials \
      --$plugin-propagation-seconds 60 \
      --email $email \
      --$hook_type-hook $hook_script \
      --domains $domains
  done
}

echo "Config: $CERTBOT_CONFIG"
parse-config | certonly
