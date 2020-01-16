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
delete noprompt obsolete;
allocate channel ch1 device type disk format '/home/oracle/backup/%U.bkp';
allocate channel ch2 device type disk format '/home/oracle/backup/%U.bkp';
allocate channel ch3 device type disk format '/home/oracle/backup/%U.bkp';
allocate channel ch4 device type disk format '/home/oracle/backup/%U.bkp';
backup database;
backup archivelog all;
delete noprompt archivelog all completed before 'sysdate-7';
release channel ch1;
release channel ch2;
release channel ch3;
release channel ch4;
}
allocate channel for maintenance device type disk;
crosscheck backupset;
delete noprompt obsolete;
exit
__EOF__

