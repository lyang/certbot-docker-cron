#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

DOMAIN="${RENEWED_DOMAINS%% *}"

copy-certs() {
  local cert
  for cert in cert.pem chain.pem fullchain.pem privkey.pem; do
    log "Copying $cert to $DOMAIN.$cert"
    cp $RENEWED_LINEAGE/$cert $RENEWED_LINEAGE/$DOMAIN.$cert
  done
}

log() {
  IFS=' ' read line method file <<< $(caller 0)
  echo "[$(basename $file)] $1"
}

copy-certs
