#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

copy-cert() {
  echo "Copying $1 to $primary.$1"
  cp $RENEWED_LINEAGE/$1 $RENEWED_LINEAGE/$primary.$1
}

convert-to-pkcs12() {
  echo "Creating PKCS12 cert $primary.pkcs12"
  openssl \
    pkcs12 -export \
    -certpbe AES-256-CBC \
    -keypbe AES-256-CBC \
    -macalg SHA256 \
    -out $RENEWED_LINEAGE/$primary.pkcs12 \
    -inkey $RENEWED_LINEAGE/$primary.privkey.pem \
    -in $RENEWED_LINEAGE/$primary.cert.pem \
    -certfile $RENEWED_LINEAGE/$primary.fullchain.pem \
    -passout pass:$primary
}

IFS=' ' read -a primary <<< "$RENEWED_DOMAINS"

echo "Running deploy-hook for $primary"

for file in cert chain fullchain privkey; do
  copy-cert $file.pem
done

convert-to-pkcs12

echo "Done"
