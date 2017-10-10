#! /bin/sh

#. /home/zabbix/etc/oraenv
. /var/lib/zabbix/bin/oraenv

#sql="select distinct tablespace_name from dba_data_files where tablespace_name<>'SYSAUX' and tablespace_name<>'SYSTEM';"
sql="select distinct tablespace_name from dba_data_files;"

echo -n "{"
echo -n "\"data\":["

#echo "$sql" | sqlplus -s /nolog @/home/zabbix/shbin/cont.sql | while read tbs
echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql |  perl -pe 's/.*/{\"{#TBSNAME}\":\"$&\"}/; s/$/,/ unless eof()' 

#echo "$sql" | sqlplus -s /nolog @/var/lib/zabbix/bin/cont.sql | while read tbs
#do
#	echo -n "{\"{#TBSNAME}\":\"${tbs}\"},"
#done


echo -n "]"
echo -n "}"


