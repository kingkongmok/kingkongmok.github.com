---
layout: post
title: "change OCR"
category: linux
tags: [oracle, ocr]
---

### install asmlib

```
yum install kmod-oracleasm
rpm -ivh oracleasmlib-2.0.4-1.el6.x86_64.rpm
```

### config asmlib

```
oracleasm init
/etc/init.d/oracleasm configure
ORACLEASM_ENABLED=true
ORACLEASM_UID=grid
ORACLEASM_GID=asmadmin
ORACLEASM_SCANBOOT=true
ORACLEASM_SCANORDER=""
ORACLEASM_SCANEXCLUDE=""
ORACLEASM_USE_LOGICAL_BLOCK_SIZE="false"

oracleasm scandisks
oracleasm listdisks
/usr/sbin/asmtool -C -l /dev/oracleasm -n FRA -s /dev/mapper/storage-fra -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n DATA2 -s /dev/mapper/storage-data -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n ORC1 -s /dev/mapper/storage-orc1 -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n ORC2 -s /dev/mapper/storage-orc2 -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n ORC3 -s /dev/mapper/storage-orc3 -a force=yes

oracleasm listdisks

reboot ?

ls -l /dev/oracleasm/disks/
```

---

### create  asm diskgroup

```
create DISKGROUP OCR NORMAL REDUNDANCY FAILGROUP ORC1 DISK 'ORCL:ORC1' name ORC1 FAILGROUP ORC2 DISK 'ORCL:ORC2' name ORC2 FAILGROUP ORC3 DISK 'ORCL:ORC3' name ORC3 attribute 'compatible.rdbms'='11.2.0.0', 'compatible.asm'='11.2.0.0' ;
CREATE DISKGROUP DATA2 EXTERNAL REDUNDANCY DISK 'ORCL:DATA2' attribute 'compatible.rdbms'='11.2.0.0', 'compatible.asm'='11.2.0.0' ;
CREATE DISKGROUP FRA EXTERNAL REDUNDANCY DISK 'ORCL:FRA'  attribute 'compatible.rdbms'='11.2.0.0', 'compatible.asm'='11.2.0.0' ;

select name,state from v$asm_diskgroup;

```

在**+ASM1**中添加磁盘组后，多次在**+ASM2**中尝试挂载/新增 diskgroup 无效，后来看介绍，在asmca中，mount all能在**+ASM2**中挂载OK。
这里可能涉及需要重启crs，才能挂载lun

### delete asmdiskgroup

在crs关闭diskgroup


```
crsctl stop resource ora.FRA.dg ora.DATA2.dg  ora.OCR.dg
crsctl delete resource ora.FRA.dg ora.DATA2.dg  ora.OCR.dg
```


只挂载一个节点，在mount的状态下才能删除diskgroup, 用**force**就可以强制删除。
如果不用force可能会出现异常，具体是检测磁盘头会出现非0，导致新建diskgroup后不能挂载。


```
alter diskgroup FRA mount ;
alter diskgroup data2 mount ;
alter diskgroup OCR mount ;
drop diskgroup data force including contents;
drop diskgroup fra including contents;
drop diskgroup data2 including contents;
drop diskgroup ocr including contents;

```

---

### [move ocr](https://www.thegeekdiary.com/how-to-move-ocr-vote-disk-file-asm-spile-to-new-diskgroup/)


. Create New diskgroup(CRS) with suitable redundancy for OCR and Voting files.
. Ensure that the new diskgroup is mounted on all cluster nodes.
. Move OCR and Vote file from [Current diskgroup] to [CRS].
. Change ASM SPFILE location from [current diskgroup] to [CRS] Diskgroup.
. Mount new [CRS] diskgroup in all nodes and restart CRS in all Nodes to Startup CRS using New SPFILE from [CRS] Diskgroup.
. Verify mount of disks and diskgroups.
. Ensure ALL Cluster Resources are started successfully .


```

create DISKGROUP OCR NORMAL REDUNDANCY FAILGROUP ORC1 DISK 'ORCL:ORC1' name ORC1 FAILGROUP ORC2 DISK 'ORCL:ORC2' name ORC2 FAILGROUP ORC3 DISK 'ORCL:ORC3' name ORC3 attribute 'compatible.rdbms'='11.2.0.0', 'compatible.asm'='11.2.0.0' ;
alter diskgroup OCR mount;
select name, state, type from v$asm_diskgroup;
```

```
sudo `which ocrconfig` -add +OCR
sudo `which ocrconfig` -delete +DATA
sudo `which crsctl` replace votedisk +OCR
crsctl query css votedisk
ocrcheck
```

change spfile location from **+DATA** to **+OCR**


```
show parameter spfile ;

create pfile='/tmp/initASM.ora' from spfile ;
create spfile='+OCR' from pfile='/tmp/initASM.ora';
```
