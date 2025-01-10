#!/bin/bash

CAT=`which cat`
GREP=`which grep`
RM=`which rm`
SED=`which sed`

NUM_OF_MONTHS=12
LAST_INVOICES_FILE="/tmp/last_invoices.txt"

### DO NOT EDIT BELOW THIS LINE ###

./fetch_last_n_invoice_uiuds.sh ${NUM_OF_MONTHS} > ${LAST_INVOICES_FILE}

REPORT_FILE_TXT="/tmp/report.txt"
REPORT_FILE_CSV="/tmp/report.csv"

echo -n "" > ${REPORT_FILE_TXT}
echo -n "" > ${REPORT_FILE_CSV}

for i in `${CAT} ${LAST_INVOICES_FILE}`; do
  echo "Invoice ${i}";
  ./fetch_detailed_costs_from_invoice_by_project.sh "$i" 2>&1 >> ${REPORT_FILE_TXT};
done

${CAT} ${REPORT_FILE_TXT}  | ${GREP} "Project\|Total costs" | ${SED} -E 's/Project "([^"]+)": ([0-9]+(\.[0-9]{1,2})?) USD/"\1";\2/' > ${REPORT_FILE_CSV}

${RM} ${LAST_INVOICES_FILE}
