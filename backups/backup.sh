#!/bin/bash

CONFIG="/usr/local/hosting.backup/backup.conf"

DATE_PREFIX1=`date -d 'now' +%Y%m%d`
DATE_PREFIX2=`date -d '7 days ago' +%Y%m%d`

BACKUP_DIRECTORY="/var/site.backups"

if [ ! -f ${CONFIG} ]; then
   echo "Config file $CONFIG doesn't exist, exiting."
   exit
fi

if [ ! -e ${BACKUP_DIRECTORY} ]; then
   echo "Backup directory $BACKUP_DIRECTORY doesn't exist, exiting."
   exit
fi

LOG_FILE_PATH=${BACKUP_DIRECTORY}/backup.${DATE_PREFIX1}.log

touch ${LOG_FILE_PATH}

while read site_config_line
do
    if [ ${site_config_line:0:1} == "#" ]; then
        continue
    fi
    
    NAME=`echo "$site_config_line" | awk '{print $1}'`
    DIRECTORY=`echo "$site_config_line" | awk '{print $2}'`
    DB_USER=`echo "$site_config_line" | awk '{print $3}'`
    DB_PASSWORD=`echo "$site_config_line" | awk '{print $4}'`
    DB_NAME=`echo "$site_config_line" | awk '{print $5}'`

    WWW_BACKUP_FILE=${NAME}.www.${DATE_PREFIX1}.tar.bz2
    WWW_BACKUP_FILE_PATH=${BACKUP_DIRECTORY}/${WWW_BACKUP_FILE}
    WWW_BACKUP_REMOVEABLE_FILE=${NAME}.www.${DATE_PREFIX2}.tar.bz2
    WWW_BACKUP_REMOVEABLE_FILE_PATH=${BACKUP_DIRECTORY}/${WWW_BACKUP_REMOVEABLE_FILE}

    echo "Backing up www files of '$NAME':" >> ${LOG_FILE_PATH}

    tar -jcvf ${WWW_BACKUP_FILE_PATH} -C ${DIRECTORY} . >> ${LOG_FILE_PATH}
    if [ -e ${WWW_BACKUP_REMOVEABLE_FILE_PATH} ]; then
        rm ${WWW_BACKUP_REMOVEABLE_FILE_PATH}
    fi

    if [ -z ${DB_USER} ]; then
        continue
    fi

    echo "Backing up db of '$NAME'." >> ${LOG_FILE_PATH}

    DB_BACKUP_FILE=${NAME}.db.${DATE_PREFIX1}.sql.bz2
    DB_BACKUP_FILE_PATH=${BACKUP_DIRECTORY}/${DB_BACKUP_FILE}
    DB_BACKUP_REMOVEABLE_FILE=${NAME}.db.${DATE_PREFIX2}.sql.bz2
    DB_BACKUP_REMOVEABLE_FILE_PATH=${BACKUP_DIRECTORY}/${DB_BACKUP_REMOVEABLE_FILE}
    echo "exit" | mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} && mysqldump -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} | bzip2 > ${DB_BACKUP_FILE_PATH}
    if [ -e ${DB_BACKUP_REMOVEABLE_FILE_PATH} ]; then
        rm ${DB_BACKUP_REMOVEABLE_FILE_PATH}
    fi
done < ${CONFIG}


LOG_FILE_REMOVEABLE_PATH=${BACKUP_DIRECTORY}/backup.${DATE_PREFIX2}.log

if [ -e ${LOG_FILE_REMOVEABLE_PATH} ]; then
    rm ${LOG_FILE_REMOVEABLE_PATH}
fi



