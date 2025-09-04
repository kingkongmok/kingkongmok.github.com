---
title: "19c rac silent install"
layout: post
category: linux
---

### env

```
bashrc

alias sqlplus='rlwrap sqlplus'
alias rman='rlwrap rman'
PS1='\[\e[0;33m\]\u@\h\[\e[m\] \[\e[1;33m\]\w\[\e[m\] \[\e[1;33m\]\$\[\e[m\] \[\e[1;37m\]'
LS_COLORS=$LS_COLORS:'di=1;36:ln=36'
```

```
oracle bash profile

export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0/db
export ORACLE_TERM=xterm
export TNS_ADMIN=$ORACLE_HOME/network/admin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export ORACLE_SID=rac1
export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
```

```
grid bash profile

export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/19.3.0/grid
export ORACLE_TERM=xterm
export TNS_ADMIN=$ORACLE_HOME/network/admin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export ORACLE_SID=+ASM1
export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH

```

--- 

### [install](https://www.modb.pro/db/154424)



### hosts

```
192.168.31.226   rac1
192.168.31.227   rac2
192.168.255.3   rac1-priv
192.168.255.4   rac2-priv
192.168.31.228   rac1-vip
192.168.31.229   rac2-vip
192.168.31.230   rac-scan

```

---


### asmlib

```
grid@rac1 ~ $ lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   50G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   49G  0 part
  ├─centos-root 253:0    0 45.1G  0 lvm  /
  └─centos-swap 253:1    0  3.9G  0 lvm  [SWAP]
sdb               8:16   0   40G  0 disk
└─sdb1            8:17   0   40G  0 part
sdc               8:32   0  100G  0 disk
└─sdc1            8:33   0  100G  0 part
sr0              11:0    1 1024M  0 rom


grid@rac1 ~ $ sudo /usr/sbin/oracleasm configure
ORACLEASM_ENABLED=true
ORACLEASM_UID=grid
ORACLEASM_GID=asmadmin
ORACLEASM_SCANBOOT=true
ORACLEASM_SCANORDER=""
ORACLEASM_SCANEXCLUDE=""
ORACLEASM_SCAN_DIRECTORIES=""
ORACLEASM_USE_LOGICAL_BLOCK_SIZE="false"

ORACLEASM_ENABLED=true
ORACLEASM_UID=grid
ORACLEASM_GID=asmadmin
ORACLEASM_SCANBOOT=true
ORACLEASM_SCANORDER=""
ORACLEASM_SCANEXCLUDE=""
ORACLEASM_SCAN_DIRECTORIES=""
ORACLEASM_USE_LOGICAL_BLOCK_SIZE="false"

grid@rac1 ~ $ sudo /usr/sbin/oracleasm listdisks
ASMDISK_DATA
ASMDISK_OCR


```
a

--- 

### grid_install.rsp

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_crsinstall_response_schema_v19.0.0
INVENTORY_LOCATION=/u01/app/oraInventory
oracle.install.option=CRS_CONFIG
ORACLE_BASE=/u01/app/grid
oracle.install.asm.OSDBA=asmdba
oracle.install.asm.OSOPER=asmoper
oracle.install.asm.OSASM=asmadmin
oracle.install.crs.config.scanType=LOCAL_SCAN
oracle.install.crs.config.SCANClientDataFile=
oracle.install.crs.config.gpnp.scanName=rac-scan
oracle.install.crs.config.gpnp.scanPort=1521
oracle.install.crs.config.ClusterConfiguration=STANDALONE
oracle.install.crs.config.configureAsExtendedCluster=false
oracle.install.crs.config.memberClusterManifestFile=
oracle.install.crs.config.clusterName=rac-cluster
oracle.install.crs.config.gpnp.configureGNS=false
oracle.install.crs.config.autoConfigureClusterNodeVIP=false
oracle.install.crs.config.gpnp.gnsOption=
oracle.install.crs.config.gpnp.gnsClientDataFile=
oracle.install.crs.config.gpnp.gnsSubDomain=
oracle.install.crs.config.gpnp.gnsVIPAddress=
oracle.install.crs.config.sites=
oracle.install.crs.config.clusterNodes=rac1:rac1-vip,rac2:rac2-vip
oracle.install.crs.config.networkInterfaceList=enp0s3:192.168.31.0:1,enp0s8:192.168.255.0:5
oracle.install.crs.configureGIMR=false
oracle.install.asm.configureGIMRDataDG=false
oracle.install.crs.config.storageOption=FLEX_ASM_STORAGE
oracle.install.crs.config.sharedFileSystemStorage.votingDiskLocations=
oracle.install.crs.config.sharedFileSystemStorage.ocrLocations=
oracle.install.crs.config.useIPMI=false
oracle.install.crs.config.ipmi.bmcUsername=
oracle.install.crs.config.ipmi.bmcPassword=
oracle.install.asm.SYSASMPassword=
oracle.install.asm.diskGroup.name=OCR
oracle.install.asm.diskGroup.redundancy=EXTERNAL
oracle.install.asm.diskGroup.AUSize=4
oracle.install.asm.diskGroup.FailureGroups=
oracle.install.asm.diskGroup.disksWithFailureGroupNames=/dev/oracleasm/disks/ASMDISK_OCR,
oracle.install.asm.diskGroup.disks=/dev/oracleasm/disks/ASMDISK_OCR
oracle.install.asm.diskGroup.quorumFailureGroupNames=
oracle.install.asm.diskGroup.diskDiscoveryString=/dev/oracleasm/disks/*
oracle.install.asm.monitorPassword=
oracle.install.asm.gimrDG.name=
oracle.install.asm.gimrDG.redundancy=
oracle.install.asm.gimrDG.AUSize=1
oracle.install.asm.gimrDG.FailureGroups=
oracle.install.asm.gimrDG.disksWithFailureGroupNames=
oracle.install.asm.gimrDG.disks=
oracle.install.asm.gimrDG.quorumFailureGroupNames=
oracle.install.asm.configureAFD=false
oracle.install.crs.configureRHPS=false
oracle.install.crs.config.ignoreDownNodes=false
oracle.install.config.managementOption=NONE
oracle.install.config.omsHost=
oracle.install.config.omsPort=0
oracle.install.config.emAdminUser=
oracle.install.config.emAdminPassword=
oracle.install.crs.rootconfig.executeRootScript=false
oracle.install.crs.rootconfig.configMethod=
oracle.install.crs.rootconfig.sudoPath=
oracle.install.crs.rootconfig.sudoUserName=
oracle.install.crs.config.batchinfo=
oracle.install.crs.app.applicationAddress=
oracle.install.crs.deleteNode.nodes=
```

install

```
${ORACLE_HOME}/gridSetup.sh -responseFile /home/grid/grid.rsp -silent -ignorePrereqFailure
```


---

### diskgroup

```
CREATE DISKGROUP DATA EXTERNAL REDUNDANCY DISK '/dev/oracleasm/disks/ASMDISK_DATA' ATTRIBUTE 'compatible.asm' = '12.1';
```

---

db_software_only.rsp

```
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v19.0.0
oracle.install.option=INSTALL_DB_SWONLY
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.OSDBA_GROUP=dba
oracle.install.db.OSOPER_GROUP=oper
oracle.install.db.OSBACKUPDBA_GROUP=backupdba
oracle.install.db.OSDGDBA_GROUP=dgdba
oracle.install.db.OSKMDBA_GROUP=kmdba
oracle.install.db.OSRACDBA_GROUP=racdba
oracle.install.db.rootconfig.executeRootScript=false
oracle.install.db.rootconfig.configMethod=
oracle.install.db.rootconfig.sudoPath=
oracle.install.db.rootconfig.sudoUserName=
oracle.install.db.CLUSTER_NODES=rac1,rac2
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=
oracle.install.db.config.starterdb.SID=
oracle.install.db.ConfigureAsContainerDB=false
oracle.install.db.config.PDBName=
oracle.install.db.config.starterdb.characterSet=
oracle.install.db.config.starterdb.memoryOption=false
oracle.install.db.config.starterdb.memoryLimit=
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.password.ALL=oracle
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.password.PDBADMIN=
oracle.install.db.config.starterdb.managementOption=DEFAULT
oracle.install.db.config.starterdb.omsHost=
oracle.install.db.config.starterdb.omsPort=0
oracle.install.db.config.starterdb.emAdminUser=
oracle.install.db.config.starterdb.emAdminPassword=
oracle.install.db.config.starterdb.enableRecovery=false
oracle.install.db.config.starterdb.storageType=
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=
oracle.install.db.config.asm.ASMSNMPPassword=
```

---


### dbca

```
responseFileVersion=/oracle/assistants/rspfmt_dbca_response_schema_v12.2.0
gdbName=oradata
sid=rac
databaseConfigType=RAC
RACOneNodeServiceName=
policyManaged=false
createServerPool=false
serverPoolName=
cardinality=
force=false
pqPoolName=
pqCardinality=
createAsContainerDatabase=true
numberOfPDBs=1
pdbName=pdb1
useLocalUndoForPDBs=true
pdbAdminPassword=
nodelist=rac1,rac2
templateName=/u01/app/oracle/product/19.3.0/db/assistants/dbca/templates/General_Purpose.dbc
sysPassword=
systemPassword=
serviceUserPassword=
emConfiguration=
emExpressPort=5500
runCVUChecks=TRUE
dbsnmpPassword=
omsHost=
omsPort=0
emUser=
emPassword=
dvConfiguration=false
dvUserName=
dvUserPassword=
dvAccountManagerName=
dvAccountManagerPassword=
olsConfiguration=false
datafileJarLocation={ORACLE_HOME}/assistants/dbca/templates/
datafileDestination=+DATA/{DB_UNIQUE_NAME}/
recoveryAreaDestination=+DATA
storageType=ASM
diskGroupName=+DATA/{DB_UNIQUE_NAME}/
asmsnmpPassword=
recoveryGroupName=+DATA
characterSet=AL32UTF8
nationalCharacterSet=AL16UTF16
registerWithDirService=false
dirServiceUserName=
dirServicePassword=
walletPassword=
listeners=
variablesFile=
variables=ORACLE_BASE_HOME=/u01/app/oracle/product/19.3.0/db,DB_UNIQUE_NAME=oradata,ORACLE_BASE=/u01/app/oracle,PDB_NAME=,DB_NAME=oradata,ORACLE_HOME=/u01/app/oracle/product/19.3.0/db,SID=rac
initParams=rac1.undo_tablespace=UNDOTBS1,rac2.undo_tablespace=UNDOTBS2,sga_target=852MB,db_block_size=8192BYTES,cluster_database=true,family:dw_helper.instance_mode=read-only,nls_language=AMERICAN,dispatchers=(PROTOCOL=TCP) (SERVICE=racXDB),diagnostic_dest={ORACLE_BASE},remote_login_passwordfile=exclusive,db_create_file_dest=+DATA/{DB_UNIQUE_NAME}/,audit_file_dest={ORACLE_BASE}/admin/{DB_UNIQUE_NAME}/adump,processes=300,pga_aggregate_target=285MB,rac1.thread=1,rac2.thread=2,nls_territory=AMERICA,local_listener=-oraagent-dummy-,db_recovery_file_dest_size=13332MB,open_cursors=300,log_archive_format=%t_%s_%r.dbf,compatible=19.0.0,db_name=oradata,rac1.instance_number=1,rac2.instance_number=2,db_recovery_file_dest=+DATA,audit_trail=db
sampleSchema=false
memoryPercentage=40
databaseType=MULTIPURPOSE
automaticMemoryManagement=false
totalMemory=0
```
