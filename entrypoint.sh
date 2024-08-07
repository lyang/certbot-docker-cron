#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

$CURRENT_DIR/scripts/certonly.sh

cp $CURRENT_DIR/scripts/renew.sh /etc/periodic/daily
exec "$@"
