#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

cp $RENEWED_LINEAGE/cert.pem $RENEWED_LINEAGE/$RENEWED_DOMAINS.cert.pem
cp $RENEWED_LINEAGE/chain.pem $RENEWED_LINEAGE/$RENEWED_DOMAINS.chain.pem
cp $RENEWED_LINEAGE/fullchain.pem $RENEWED_LINEAGE/$RENEWED_DOMAINS.fullchain.pem
cp $RENEWED_LINEAGE/privkey.pem $RENEWED_LINEAGE/$RENEWED_DOMAINS.privkey.pem

openssl \
  pkcs12 -export \
  -certpbe AES-256-CBC \
  -keypbe AES-256-CBC \
  -macalg SHA256 \
  -out $RENEWED_LINEAGE/$RENEWED_DOMAINS.pkcs12 \
  -inkey $RENEWED_LINEAGE/$RENEWED_DOMAINS.privkey.pem \
  -in $RENEWED_LINEAGE/$RENEWED_DOMAINS.cert.pem \
  -certfile $RENEWED_LINEAGE/$RENEWED_DOMAINS.fullchain.pem \
  -passout pass:$RENEWED_DOMAINS
