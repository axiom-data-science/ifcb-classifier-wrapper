#!/bin/bash

# ifcb_classifier can't just be given start and end dates. You can either point it at an 
# entire directory or pass individual dates to --filter IN that you want included.
# Alternatively you can pass a file with a date per line; that's what we're doing here
# since the list could potentially include hundreds of dates.
if [ -n "$STARTDATE" ] && [ -n "$ENDDATE" ]; then
  for d in $(seq $(date +%s -d "$STARTDATE") +86400 $(date +%s -d "$ENDDATE")); do
    date -u +%Y%m%d -d @$d >> /tmp/ifcb-classifier-dates;
  done
fi

python "$@"
