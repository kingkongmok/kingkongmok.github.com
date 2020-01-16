#!/bin/sh

# CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;
# CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+DATA/${db_unique_name}/controlfile/snapcf_${db_unique_name}.f';

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export ORACLE_SID=rac1
export PATH=$ORACLE_HOME/bin:$PATH
rman target / << __EOF__
run
{
crosscheck backup;
DELETE noprompt OBSOLETE;
allocate channel ch1 device type disk format '/home/oracle/backup/%U.bkp';
allocate channel ch2 device type disk format '/home/oracle/backup/%U.bkp';
allocate channel ch3 device type disk format '/home/oracle/backup/%U.bkp';
allocate channel ch4 device type disk format '/home/oracle/backup/%U.bkp';
backup database;
backup archivelog all;
DELETE NOPROMPT ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-7';
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
}
ALLOCATE CHANNEL FOR MAINTENANCE DEVICE TYPE DISK;
CROSSCHECK BACKUPSET;
DELETE NOPROMPT OBSOLETE;
EXIT
__EOF__

