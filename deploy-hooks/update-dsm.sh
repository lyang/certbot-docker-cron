#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

update-dsm() {
  CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  $CURRENT_DIR/default.sh
  DSM_CONFIG=$1
  IFS=' ' read -a DOMAIN <<< "$RENEWED_DOMAINS"
  IFS=' ' read SCHEME HOST PORT ACCOUNT PASSWD <<< $(parse-config)
  QUERY_URL="$SCHEME://$HOST:$PORT/webapi/query.cgi"
  IFS=' ' read API_PATH API_VERSION <<< $(get-api-info)
  API_URL="$SCHEME://$HOST:$PORT/webapi/$API_PATH"
  IFS=' ' read SID DEVICE_ID SYNO_TOKEN <<< $(get-auth-token)
  DEFAULT_CERT=$(get-default-cert)
  replace-default-cert
}

parse-config() {
  jq --raw-output '[.scheme, .host, .port, .account, .passwd] | join(" ")' $DSM_CONFIG
}

get-api-info() {
  curl --silent \
    --data "api=SYNO.API.Info" \
    --data "version=1" \
    --data "method=query" \
    --data "query=SYNO.API.Auth" \
    $QUERY_URL | \
    jq --raw-output '.data["SYNO.API.Auth"] | [.path, (.maxVersion | tostring)] | join(" ")' 
}

get-auth-token() {
  curl --silent \
    --data "api=SYNO.API.Auth" \
    --data "version=7" \
    --data "method=login" \
    --data "format=sid" \
    --data "enable_syno_token=yes" \
    --data "account=$ACCOUNT" \
    --data "passwd=$PASSWD" \
    $API_URL | \
    jq --raw-output '.data | [.sid, .device_id, .synotoken] | join(" ")'
}

get-default-cert() {
  curl --silent \
    --header "X-SYNO-TOKEN: $SYNO_TOKEN" \
    --request POST \
    --data "api=SYNO.Core.Certificate.CRT" \
    --data "method=list" \
    --data "version=1" \
    --data "_sid=$SID" \
    $API_URL | \
    jq --raw-output '.data.certificates.[] | select(.is_default) | .id'
}

replace-default-cert() {
  curl --silent \
    --request POST \
    --data "api=SYNO.Core.Certificate" \
    --data "method=import" \
    --data "version=1" \
    --data "SynoToken=$SYNO_TOKEN" \
    --data "_sid=$SID" \
    --form "key=@$DOMAIN.privkey.pem" \
    --form "cert=@$DOMAIN.cert.pem" \
    --form "inter_cert=@$DOMAIN.chain.pem" \
    --form "id=$DEFAULT_CERT" \
    --form "as_default=true" \
    $API_URL | \
    jq "."
}

update-dsm $1
