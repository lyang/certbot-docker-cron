#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

run-parts /etc/periodic/daily

exec "$@"
