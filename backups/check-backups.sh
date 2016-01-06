#!/bin/sh

EXIT_STATUS=0
BACKUP_FILES=`ls *.bz2 2>/dev/null`

if [ -z "$BACKUP_FILES" ]; then
	echo "No backup files found!"
	exit 1
fi

for BACKUP_FILE in $BACKUP_FILES; do
	if ! bzip2 -q -t $BACKUP_FILE > /dev/null 2>&1; then
		echo "$BACKUP_FILE is not ok"
		EXIT_STATUS=2
	fi
done

exit $EXIT_STATUS