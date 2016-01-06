#!/bin/sh

EMAIL_TO=""
REPORT_CMD="./check-backups.sh"

HOSTNAME=`hostname`
EMAIL_SUBJECT=`printf "Backup check report [%s]" "$HOSTNAME"`

REPORT=`$REPORT_CMD`
if [ ! $? = 0 ]; then
    echo "$REPORT" | mail -s "$EMAIL_SUBJECT" "$EMAIL_TO"
fi