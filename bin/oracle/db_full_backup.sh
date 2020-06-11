#!/bin/sh

# CONFIGURE CONTROLFILE AUTOBACKUP ON;
# CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/mnt/nas/rman/%F';
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
allocate channel ch1 device type disk format '/mnt/nas/rman/%U.bkp';
allocate channel ch2 device type disk format '/mnt/nas/rman/%U.bkp';
allocate channel ch3 device type disk format '/mnt/nas/rman/%U.bkp';
allocate channel ch4 device type disk format '/mnt/nas/rman/%U.bkp';
backup as compressed backupset database plus archivelog;
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

