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
DIGITALOCEAN_TOKEN=`${CAT} .digitalocean_credentials | ${GREP} "DIGITALOCEAN_TOKEN" | ${CUT} -f 2 -d "=" | ${TR} -d '"'`

echo "Using DIGITALOCEAN_TOKEN: ${DIGITALOCEAN_TOKEN}..."

invoice_id=""

if [ "x$1" == "x" ]; then
  invoice_id=""
else
  invoice_id="$1"
fi

PER_PAGE=200
INVOICES_JSON_FILE="invoices.json"

CONTENT_TYPE_HEADER="Content-Type: application/json"
AUTHORIZATION_HEADER="Authorization: Bearer ${DIGITALOCEAN_TOKEN}"

if [ "x${invoice_id}" == "x" ]; then
  echo "Getting list of invoices..."
  ${CURL} -X GET -H "${CONTENT_TYPE_HEADER}" -H "${AUTHORIZATION_HEADER}" \
    "${DIGITALOCEAN_API_HOST}/v2/customers/my/invoices?per_page=1" > ${INVOICES_JSON_FILE}
  invoice_id=`${CAT} ${INVOICES_JSON_FILE} | ${JQ} -c ".invoices[].invoice_uuid"| ${TR} -d '"'`
fi

JSON_FILE="invoice_${invoice_id}.json"

$CURL -X GET -H "${CONTENT_TYPE_HEADER}" -H "${AUTHORIZATION_HEADER}" \
  "${DIGITALOCEAN_API_HOST}/v2/customers/my/invoices/${invoice_id}?per_page=${PER_PAGE}" > ${JSON_FILE}

project_names=`${CAT} ${JSON_FILE}| ${JQ} -c ".invoice_items[].project_name" | ${SORT} | ${UNIQ}`

echo "Total costs per project from invoice: ${invoice_id}"

while IFS= read -r project_name; do
  total_costs=`${CAT} ${JSON_FILE}| ${JQ} -c "[.invoice_items[] | select(.project_name == ${project_name}) | .amount | tonumber] | add"`
  echo "Project ${project_name}: ${total_costs} USD"
done <<< "$project_names"

${RM} -f ${JSON_FILE}
${RM} -f ${INVOICES_JSON_FILE}
