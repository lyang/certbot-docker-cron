#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

IFS=' ' read -a DOMAIN <<< "$RENEWED_DOMAINS"

for file in cert.pem chain.pem fullchain.pem privkey.pem; do
  echo "Copying $file to $DOMAIN.$file"
  cp $RENEWED_LINEAGE/$file $RENEWED_LINEAGE/$DOMAIN.$file
done
