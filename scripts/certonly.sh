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
    '(."hook-type" // "deploy")'
    '(."hook-script" // "/etc/certbot/deploy-hooks/default.sh")'
    '(."hook-config" // "")'
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
  local domains email plugin credentials hook_type hook_script hook_config
  while read domains email plugin credentials hook_type hook_script hook_config; do
    echo "Creating for $domains ..."
    HOOK_CONFIG="$hook_config" certbot \
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
