#!/bin/bash
source "$HOME/bin/shell-proteins/bash/base.inc.sh"

# Import core functions
protein_require "core/print_usage"
protein_require "grzegorzblaszczyk/shell-proteins-ext/bash/os/get_os_version"
os_version="`get_os_version`"

case "${os_version}" in
MacOSX)
  os="mac"
  ;;
Ubuntu)
  os="ubuntu"
  ;;
*)
  os="unknown"
  ;;
esac

SSH_KEY_ID=$1

if [ "x${SSH_KEY_ID}" == "x" ]; then
  echo "Usage: ${0} [key_id_from_DigitalOcean]"
  exit 1
fi

protein_require "grzegorzblaszczyk/shell-proteins-ext/bash/${os}/verify_if_installed_with_dot"

verify_if_installed_with_dot "curl" "/usr/bin/curl"
verify_if_installed_with_dot "jq" "/usr/local/bin/jq"
verify_if_installed_with_dot "tr" "/usr/bin/tr"

echo ""

DEBUG="${DEBUG:-false}"

CAT=`which cat`
CURL=`which curl`
CUT=`which cut`
GREP=`which grep`
JQ=`which jq`
RM=`which rm`
SORT=`which sort`
TR=`which tr`
UNIQ=`which uniq`

DIGITALOCEAN_API_HOST="https://api.digitalocean.com"
DIGITALOCEAN_TOKEN=`${CAT} .digitalocean_credentials_ssh_keys | ${GREP} "DIGITALOCEAN_TOKEN" | ${CUT} -f 2 -d "=" | ${TR} -d '"'`

echo "Using DIGITALOCEAN_TOKEN: ${DIGITALOCEAN_TOKEN}..."

CONTENT_TYPE_HEADER="Content-Type: application/json"
AUTHORIZATION_HEADER="Authorization: Bearer ${DIGITALOCEAN_TOKEN}"

echo "Deleting SSH key with ID: ${SSH_KEY_ID} ..."

${CURL} -vvvv -X DELETE \
  -H "${CONTENT_TYPE_HEADER}" \
  -H "${AUTHORIZATION_HEADER}" \
  "${DIGITALOCEAN_API_HOST}/v2/account/keys/${SSH_KEY_ID}"

