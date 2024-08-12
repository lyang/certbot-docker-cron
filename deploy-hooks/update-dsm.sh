#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $CURRENT_DIR/default.sh

update-dsm() {
  log "Parsing config from $DSM_CONFIG"
  IFS=' ' read SCHEME HOST PORT ACCOUNT PASSWD <<< $(parse-config)

  BASE_URL="$SCHEME://$HOST:$PORT/webapi"
  log "Getting API info from $BASE_URL"
  IFS=' ' read API_PATH API_VERSION <<< $(get-api-info)

  API_URL="$BASE_URL/$API_PATH"
  log "Getting API token from $API_URL"
  IFS=' ' read SID SYNO_TOKEN <<< $(get-auth-token)

  DEFAULT_CERT=$(get-default-cert)
  log "Replacing default cert $DEFAULT_CERT"
  replace-default-cert
  log "Done"
}

parse-config() {
  jq --raw-output '[.scheme, .host, .port, .account, .passwd] | join(" ")' $DSM_CONFIG
}

get-api-info() {
  local query_url="$BASE_URL/query.cgi"
  curl --silent --insecure \
    --data "api=SYNO.API.Info" \
    --data "version=1" \
    --data "method=query" \
    --data "query=SYNO.API.Auth" \
    $query_url | \
    jq --raw-output '.data["SYNO.API.Auth"] | [.path, (.maxVersion | tostring)] | join(" ")' 
}

get-auth-token() {
  curl --silent --insecure \
    --data "api=SYNO.API.Auth" \
    --data "version=$API_VERSION" \
    --data "method=login" \
    --data "format=sid" \
    --data "enable_syno_token=yes" \
    --data "account=$ACCOUNT" \
    --data-urlencode "passwd=$PASSWD" \
    $API_URL | \
    jq --raw-output '.data | [.sid, .synotoken] | join(" ")'
}

get-default-cert() {
  curl --silent --insecure \
    --header "X-SYNO-TOKEN: $SYNO_TOKEN" \
    --request POST \
    --data "api=SYNO.Core.Certificate.CRT" \
    --data "method=list" \
    --data "version=1" \
    --data "_sid=$SID" \
    $API_URL | \
    jq --raw-output '.data.certificates[] | select(.is_default) | .id'
}

replace-default-cert() {
  curl --silent --insecure \
    --request POST \
    --form "key=@$RENEWED_LINEAGE/$DOMAIN.privkey.pem" \
    --form "cert=@$RENEWED_LINEAGE/$DOMAIN.cert.pem" \
    --form "inter_cert=@$RENEWED_LINEAGE/$DOMAIN.chain.pem" \
    --form "id=$DEFAULT_CERT" \
    --form "desc=$DOMAIN" \
    --form "as_default=true" \
    "$API_URL?api=SYNO.Core.Certificate&method=import&version=1&SynoToken=$SYNO_TOKEN&_sid=$SID&" | \
    jq --compact-output '.'
}

update-dsm
