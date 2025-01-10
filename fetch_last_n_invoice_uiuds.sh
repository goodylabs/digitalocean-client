#!/bin/bash

CUT=`which cut`
GREP=`which grep`
HEAD=`which head`

if [ "x$1" == "x" ]; then
  echo "Usage: $0 [number_of_invoices]"
  exit 1
fi

NUM_OF_INVOICES=$1

./fetch_invoices.sh | ${GREP} "invoice_uuid" | ${HEAD} -${NUM_OF_INVOICES} | ${CUT} -f 4 -d '"'
