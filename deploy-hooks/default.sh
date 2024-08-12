#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

DOMAIN="${RENEWED_DOMAINS%% *}"

copy-certs() {
  local file
  for file in cert.pem chain.pem fullchain.pem privkey.pem; do
    echo "Copying $file to $DOMAIN.$file"
    cp $RENEWED_LINEAGE/$file $RENEWED_LINEAGE/$DOMAIN.$file
  done
}

copy-certs
