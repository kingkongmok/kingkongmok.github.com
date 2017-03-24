---
title: "oracle install"
layout: post
category: linux
---

## enviroment setting

```
groupadd dba
groupadd oper
groupadd asmdba
groupadd asmoper
groupadd asmadmin

usermod -g oinstall -G dba,oper,asmdba,asmoper,asmadmin oracle

mkdir -p /u01/app/oraInventory
mkdir -p /u01/app/oracle/oradata
mkdir -p /u01/app/oracle/fast_recovery_area
mkdir -p /stage
chown -R oracle:oinstall /u01/app/
chown -R oracle:oinstall /stage/
chmod -R 775 /u01/app/
chmod -R 775 /stage/

cat >> ~/.bashrc << EOF

PS1='\[\e[0;33m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=30000
HISTFILESIZE=300000
HISTTIMEFORMAT="%F %T "

LANG="en_US.utf8"
LC_ALL="en_US.utf8"
export EDITOR="vim"

# User specific aliases and functions
TMOUT=18000

# oralce enviroment
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export ORACLE_SID=orcl
export PATH=/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/oracle/bin
EOF
```



## Error with responseFile config

### db.rsp 文件内容：

```
$ grep -vP '^\s*(#|$)' /home/oracle/db.rsp
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=localhost
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.EEOptionsSelection=false
oracle.install.db.optionalComponents=
oracle.install.db.DBA_GROUP=oper
oracle.install.db.OPER_GROUP=oper
oracle.install.db.CLUSTER_NODES=
oracle.install.db.isRACOneInstall=false
oracle.install.db.racOneServiceName=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=
oracle.install.db.config.starterdb.SID=
oracle.install.db.config.starterdb.characterSet=
oracle.install.db.config.starterdb.memoryOption=false
oracle.install.db.config.starterdb.memoryLimit=
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.password.ALL=
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.SYSMAN=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.control=DB_CONTROL
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=
oracle.install.db.config.starterdb.automatedBackup.enable=false
oracle.install.db.config.starterdb.automatedBackup.osuid=
oracle.install.db.config.starterdb.automatedBackup.ospwd=
oracle.install.db.config.starterdb.storageType=
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=
oracle.install.db.config.asm.ASMSNMPPassword=
MYORACLESUPPORT_USERNAME=
MYORACLESUPPORT_PASSWORD=
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
PROXY_REALM=
COLLECTOR_SUPPORTHUB_URL=
oracle.installer.autoupdates.option=SKIP_UPDATES
oracle.installer.autoupdates.downloadUpdatesLoc=
AUTOUPDATES_MYORACLESUPPORT_USERNAME=oracle
AUTOUPDATES_MYORACLESUPPORT_PASSWORD=

```

---

```
./database/runInstaller -silent -responseFile /home/oracle/db.rsp
```

### ERROR

> Checking Temp space: must be greater than 500 MB.   Actual 45136 MB    Passed
> Checking swap space: must be greater than 150 MB.   Actual 4031 MB    Passed
> Preparing to launch Oracle Universal Installer from /tmp/OraInstall2013-06-27_12-11-01AM. Please wait ...
> [oracle@pandora database]$ [FATAL] PRVF-0002 : Could not retrieve local nodename
> A log of this session is currently saved as: [..]

### [方法](https://www.krenger.ch/blog/fatal-prvf-0002-could-not-retrieve-local-nodename/)

> *** End of Installation Page***
> The installation of Oracle Database 11g was successful.
> INFO: Updating the global context
> INFO: Path To 'globalcontext.xml' = /u01/app/oracle/product/11.2.0/dbhome_1/install/chainedInstall/globalcontext
> INFO: Since operation was successful, move the current OiicAPISessionDetails to installed list
> INFO: Number of scripts to be executed as root user = 2
> INFO: isSuccessfullInstallation: true
> INFO: isSuccessfullRemoteInstallation: true
> INFO: Adding ExitStatus SUCCESS to the exit status set
> INFO: Completed setting up InstallDB
> INFO: Number of scripts to be executed as root user = 2
> INFO: Shutting down OUISetupDriver.JobExecutorThread
> INFO: Cleaning up, please wait...
> INFO: Dispose the install area control object
> INFO: Update the state machine to STATE_CLEAN
> INFO: All forked task are completed at state setup
> INFO: Completed background operations
> INFO: Moved to state <setup>
> INFO: Waiting for completion of background operations
> INFO: Completed background operations
> INFO: Validating state <setup>
> INFO: Completed validating state <setup>
