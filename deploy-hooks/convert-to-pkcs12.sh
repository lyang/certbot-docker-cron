#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

$CURRENT_DIR/default.sh

IFS=' ' read -a DOMAIN <<< "$RENEWED_DOMAINS"
echo "Creating PKCS12 cert $DOMAIN.pkcs12"
openssl \
  pkcs12 -export \
  -certpbe AES-256-CBC \
  -keypbe AES-256-CBC \
  -macalg SHA256 \
  -out $RENEWED_LINEAGE/$DOMAIN.pkcs12 \
  -inkey $RENEWED_LINEAGE/$DOMAIN.privkey.pem \
  -in $RENEWED_LINEAGE/$DOMAIN.cert.pem \
  -certfile $RENEWED_LINEAGE/$DOMAIN.fullchain.pem \
  -passout pass:$DOMAIN
