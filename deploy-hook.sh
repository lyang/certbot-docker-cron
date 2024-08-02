#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

cp $RENEWED_LINEAGE/cert.pem $RENEWED_LINEAGE/$RENEWED_DOMAINS.cert.pem
cp $RENEWED_LINEAGE/chain.pem $RENEWED_LINEAGE/$RENEWED_DOMAINS.chain.pem
cp $RENEWED_LINEAGE/fullchain.pem $RENEWED_LINEAGE/$RENEWED_DOMAINS.fullchain.pem
cp $RENEWED_LINEAGE/privkey.pem $RENEWED_LINEAGE/$RENEWED_DOMAINS.privkey.pem
