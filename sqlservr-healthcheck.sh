#!/bin/bash

HEALTHCHECK_QUERY="\
SELECT \
   name, state_desc \
FROM \
   sys.databases \
WHERE \
   state IN (4, 5, 6) \
"

# allow passing custom query as the first argument of this script
HEALTHCHECK_QUERY=${1:-"$HEALTHCHECK_QUERY"}

# get the result format like:
## name                     state_desc
## ------------------------ --------------
## master                   ONLINE
## tempdb                   ONLINE
## model                    ONLINE
## msdb                     ONLINE
##
## (4 rows affected)
HEALTHCHECK_QUERY_RESULT="$(sqlcmd -l 15 -t 15 -S localhost -U sa -P "$SA_PASSWORD" -Q "$HEALTHCHECK_QUERY")"

# show the result if someone needs it
echo "$HEALTHCHECK_QUERY_RESULT"

UNHEALTY_DATABASES_COUNT="$(echo "$HEALTHCHECK_QUERY_RESULT" | grep 'rows affected)' | sed 's/^(\([[:alnum:]]\+\) rows affected)$/\1/g')"

if [[ UNHEALTY_DATABASES_COUNT -ne "0" ]]; then
  # There are more than 0 UNHEALTY databases
  exit 1;
fi

# All is good!
exit 0;
