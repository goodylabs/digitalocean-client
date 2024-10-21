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

PER_PAGE=200
KEYS_JSON_FILE="keys.json"

CONTENT_TYPE_HEADER="Content-Type: application/json"
AUTHORIZATION_HEADER="Authorization: Bearer ${DIGITALOCEAN_TOKEN}"

echo "Getting list of SSH keys..."
${CURL} -X GET -H "${CONTENT_TYPE_HEADER}" -H "${AUTHORIZATION_HEADER}" \
"${DIGITALOCEAN_API_HOST}/v2/account/keys?per_page=100" > ${KEYS_JSON_FILE}

${CAT} ${KEYS_JSON_FILE}

${CAT} ${KEYS_JSON_FILE} | ${JQ} '.ssh_keys[]'

if [ "x${DEBUG}" == "xfalse" ]; then
  ${RM} -f ${KEYS_JSON_FILE} ${JSON_FILE}
fi
