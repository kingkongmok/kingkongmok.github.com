#!/bin/bash -
set -o nounset                              # Treat unset variables as an error

local_ip=`ip ro | grep bond0  | grep 'proto kernel' | awk '{print $9}' | tail -1`
timestamp=`date +"%F_%T"`
mysql_databasename="DB_NAME"
mysql_username=root
mysql_password=ROOTPASSWORD
logfile=/tmp/${mysql_databasename}_mysql_backup.log
exec 1>> $logfile 2>&1

/usr/local/mysql/bin/mysqldump -u${mysql_username} -p${mysql_password} --all-databases > "/backup/${local_ip}_${mysql_databasename}_${timestamp}.sql"
/bin/gzip --best -f "/backup/${local_ip}_${mysql_databasename}_${timestamp}.sql"
cd /backup && ls -tp ${local_ip}_${mysql_databasename}_*.sql.gz | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {}
rsync --delete -aviPh /backup/ mysqlbackup@BACKUPSERVER_HOSTNAME:./${local_ip}/
