#! /bin/bash
set -o errexit
set -o nounset
set -o pipefail

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $CURRENT_DIR/default.sh

parse-config() {
  jq --raw-output '[.scheme, .host, .port, .account, .passwd] | join(" ")' $HOOK_CONFIG
}

get-api-info() {
  local scheme host port
  IFS=' ' read scheme host port ACCOUNT PASSWD <<< $(parse-config)
  BASE_URL="$scheme://$host:$port/webapi"
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
  local api_path api_version
  IFS=' ' read api_path api_version <<< $(get-api-info)
  API_URL="$BASE_URL/$api_path"
  curl --silent --insecure \
    --data "api=SYNO.API.Auth" \
    --data "version=$api_version" \
    --data "method=login" \
    --data "format=sid" \
    --data "enable_syno_token=yes" \
    --data "account=$ACCOUNT" \
    --data "passwd=$PASSWD" \
    $API_URL | \
    jq --raw-output '.data | [.sid, .synotoken] | join(" ")'
}

get-default-cert() {
  IFS=' ' read SID SYNO_TOKEN <<< $(get-auth-token)
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
  DEFAULT_CERT=$(get-default-cert)
  curl --silent --insecure \
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

replace-default-cert
