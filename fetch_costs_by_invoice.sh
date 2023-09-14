#!/bin/bash

CAT=`which cat`
CURL=`which curl`
CUT=`which cut`
GREP=`which grep`
JQ=`which jq`
RM=`which rm`
SORT=`which sort`
TR=`which tr`
UNIQ=`which uniq`

DIGITALOCEAN_TOKEN=`${CAT} .digitalocean_credentials | ${GREP} "DIGITALOCEAN_TOKEN" | ${CUT} -f 2 -d "=" | ${TR} -d '"'`

echo "Using DIGITALOCEAN_TOKEN: ${DIGITALOCEAN_TOKEN}..."

INVOICE_ID=""

if [ "x$1" == "x" ]; then
  INVOICE_ID=""
else
  INVOICE_ID="$1"
fi

PER_PAGE=200
INVOICES_JSON_FILE="invoices.json"

if [ "x${INVOICE_ID}" == "x" ]; then
  echo "Getting list of invoices..."
  ${CURL} -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DIGITALOCEAN_TOKEN}" \
    "https://api.digitalocean.com/v2/customers/my/invoices?per_page=1" > ${INVOICES_JSON_FILE}
  INVOICE_ID=`${CAT} ${INVOICES_JSON_FILE} | ${JQ} -c ".invoices[].invoice_uuid"| ${TR} -d '"'`
fi

JSON_FILE="invoice_${INVOICE_ID}.json"

$CURL -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${DIGITALOCEAN_TOKEN}" \
  "https://api.digitalocean.com/v2/customers/my/invoices/${INVOICE_ID}?per_page=${PER_PAGE}" > ${JSON_FILE}

project_names=`${CAT} ${JSON_FILE}| ${JQ} -c ".invoice_items[].project_name" | ${SORT} | ${UNIQ}`

echo "Total costs per project from invoice: ${INVOICE_ID}"

while IFS= read -r project_name; do
  total_costs=`${CAT} ${JSON_FILE}| ${JQ} -c "[.invoice_items[] | select(.project_name == ${project_name}) | .amount | tonumber] | add"`
  echo "Project ${project_name}: ${total_costs} USD"
done <<< "$project_names"

${RM} -f ${JSON_FILE}
${RM} -f ${INVOICES_JSON_FILE}