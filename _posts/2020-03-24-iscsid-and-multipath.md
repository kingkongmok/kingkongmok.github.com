---
layout: post
title: "iscsid and multipath"
category: linux
tags: [centos, san, iscsi, multipath]
---

### hosts


```
cat >> /etc/hosts << EOF

# primary db
10.255.255.21   rac1
10.255.255.22   rac2
10.255.255.23   rac1-vip
10.255.255.24   rac2-vip
10.255.255.25   rac-scan
192.168.0.1     rac1-priv
192.168.0.2     rac2-priv

# standby db
10.255.255.121  stb1
10.255.255.122  stb2
10.255.255.123  stb1-vip
10.255.255.124  stb2-vip
10.255.255.125  stb-scan
192.168.0.21    stb1-priv
192.168.0.22    stb2-priv

# storage
10.255.255.150  storage
192.168.0.150     storage-priv1
192.168.1.150     storage-priv2
EOF

```

---

### [mdadm](https://www.thegeekdiary.com/redhat-centos-managing-software-raid-with-mdadm/)

check

```
mdadm --detail /dev/md0
```

create

```
mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 /dev/sdb /dev/sdc /dev/sdd /dev/sde --spare-devices=1 /dev/sdf
mdadm --detail /dev/md0

/dev/md0:
        Version : 1.2
  Creation Time : Thu Mar 26 10:00:51 2020
     Raid Level : raid10
     Array Size : 25149440 (23.98 GiB 25.75 GB)
  Used Dev Size : 12574720 (11.99 GiB 12.88 GB)
   Raid Devices : 4
  Total Devices : 5
    Persistence : Superblock is persistent

    Update Time : Thu Mar 26 10:02:42 2020
          State : clean, resyncing
 Active Devices : 4
Working Devices : 5
 Failed Devices : 0
  Spare Devices : 1

         Layout : near=2
     Chunk Size : 512K

  Resync Status : 88% complete

           Name : storage:0  (local to host storage)
           UUID : 13532709:95d3fe13:860e6618:e3472db3
         Events : 14

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde

       4       8       80        -      spare   /dev/sdf

```

save 

```
mdadm --verbose --detail -scan > /etc/mdadm.conf
```

restore other machinne?

```
cat /etc/mdadm.conf
mdadm --assemble /dev/md0
```

stop and remove

```
mdadm --stop /dev/md0
mdadm --remove /dev/md0
mdadm --zero-superblock /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf
```

---

### [lvm](https://geekpeek.net/lvm-physical-volume-management/)

```

pvcreate /dev/md0
vgcreate storage /dev/md0
lvcreate -n data -L 25GiB storage
lvcreate -n fra -L 5GiB storage
lvcreate -n ocr1 -L 1GiB storage
lvcreate -n ocr2 -L 1GiB storage
lvcreate -n ocr3 -L 1GiB storage

```

---

### [scsi-taget as service](https://www.cnblogs.com/jyzhao/p/7200585.html)

install

```
yum -y install scsi-target-utils sg3_utils
```

config

```
cat >> /etc/tgt/targets.conf << EOF

default-driver iscsi
<target iqn.2020-03.com.example:storage.target4>
        backing-store /dev/mapper/storage-orc1
        backing-store /dev/mapper/storage-orc2
        backing-store /dev/mapper/storage-orc3
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
</target>

<target iqn.2020-04.com.example:storage.data>
        backing-store /dev/mapper/storage-data
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
</target>
<target iqn.2020-04.com.example:storage.fra>
        backing-store /dev/mapper/storage-fra
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
</target>
<target iqn.2020-04.com.example:storage.dg-fra>
        backing-store /dev/mapper/storage-dg--fra
        write-cache on
        initiator-address 192.168.0.21
        initiator-address 192.168.1.21
        initiator-address 192.168.0.22
        initiator-address 192.168.1.22
</target>
<target iqn.2020-04.com.example:storage.dg-data>
        backing-store /dev/mapper/storage-dg--data
        write-cache on
        initiator-address 192.168.0.21
        initiator-address 192.168.1.21
        initiator-address 192.168.0.22
        initiator-address 192.168.1.22
</target>
<target iqn.2020-04.com.example:storage.dg-ocr1>
        backing-store /dev/mapper/storage-dg--ocr1
        write-cache on
        initiator-address 192.168.0.21
        initiator-address 192.168.1.21
        initiator-address 192.168.0.22
        initiator-address 192.168.1.22
</target>

<target iqn.2020-04.com.example:storage.dg-ocr2>
        backing-store /dev/mapper/storage-dg--ocr2
        write-cache on
        initiator-address 192.168.0.21
        initiator-address 192.168.1.21
        initiator-address 192.168.0.22
        initiator-address 192.168.1.22
</target>

<target iqn.2020-04.com.example:storage.dg-ocr3>
        backing-store /dev/mapper/storage-dg--ocr3
        write-cache on
        initiator-address 192.168.0.21
        initiator-address 192.168.1.21
        initiator-address 192.168.0.22
        initiator-address 192.168.1.22
</target>
EOF
```

service start 

```
service tgtd start
```

check

```
tgt-admin --show
```

### [update tgtd without restart](https://blog.delouw.ch/2013/07/07/creating-and-managing-iscsi-targets/)

```
tgt-admin --update ALL --force
```

---


### [scsi-initiator as client](https://www.cnblogs.com/jyzhao/p/7200585.html)


```
yum install iscsi-initiator-utils
```

discover

```
sudo iscsiadm -m discovery -t sendtargets -p storage-priv1
sudo iscsiadm -m discovery -t sendtargets -p storage-priv2
```

check

```
iscsiadm -m node -P 0
```

~~set~~

```
iscsiadm -m node -p 10.255.255.150:3260,1 -T iqn.2008-09.com.example:server.target3 -l
iscsiadm -m node -p 192.168.255.150:3260,1 -T iqn.2008-09.com.example:server.target3 -l
```

~~unset~~

```
sudo /etc/init.d/iscsi restart
sudo iscsiadm -m node -P 0
sudo iscsiadm -m node -T iqn.2020-03.com.example:storage.target4 -p 192.168.1.150:3260,1 -u
sudo iscsiadm -m node -T iqn.2020-03.com.example:storage.target4 -p 192.168.1.150:3260,1 -o delete
```

### restart iscsi, 用于线路修复

```
sudo /etc/init.d/iscsi restart
```

---

### mulipath

```
yum install device-mapper-multipath
```

```
/sbin/mpathconf --enable
/etc/init.d/multipathd restart
multipath -ll
```


edit **/etc/multipath.conf**

```

defaults {
        user_friendly_names yes
        getuid_callout "/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/%n"
}

blacklist {
        devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*"
}

multipaths {
        multipath {
                wwid      1IET_00010001
                alias     storage-orc1
        }
        multipath {
                wwid      1IET_00010002
                alias     storage-orc2
        }
        multipath {
                wwid      1IET_00010003
                alias     storage-orc3
        }
        multipath {
                wwid      1IET_00020001
                alias     storage-data
        }
        multipath {
                wwid      1IET_00080001
                alias     storage-fra
        }
}

```

```
#set alias
multipath -F
/etc/init.d/multipathd restart
multipath -ll
```

---

### [resize](https://ronekins.wordpress.com/2016/11/21/resizing-oracle-asm-disks/)


on storage



```
mdadm --verbose --detail /dev/md0
mdadm --add /dev/md0 /dev/sdg /dev/sdi /dev/sdh

 Active Devices : 4
 Working Devices : 8
```

会看到多了3个热备盘, 共8个

```
mdadm --grow /dev/md0 --raid-devices=7
mdadm --detail /dev/md0
 Active Devices : 7
 Working Devices : 8
```



```
/etc/init.d/tgtd stop
pvresize /dev/md0
vgdisplay
lvextend -l +100%FREE storage-fra
lvextend -L 20G storage-fra
/etc/init.d/tgtd start
```

on db server

```
sudo /etc/init.d/iscsi stop
sudo /etc/init.d/multipathd stop
# sudo multipathd --disable
# sudo multipathd -k'resize map storage-fra'
sql> select name, total_mb/(1024) "Total GiB" from v$asm_diskgroup;
sql> alter diskgroup FRA resize all;
```


---

### asmlib

```
/etc/init.d/oracleasm restart
```

```
/etc/init.d/oracleasm configure
oracleasm scandisks
oracleasm listdisks
/usr/sbin/asmtool -C -l /dev/oracleasm -n FRA -s /dev/mapper/storage-fra -a force=yes
oracleasm listdisks
/usr/sbin/asmtool -C -l /dev/oracleasm -n DATA2 -s /dev/mapper/storage-data -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n OCR1 -s /dev/mapper/storage-ocr1 -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n OCR2 -s /dev/mapper/storage-ocr2 -a force=yes
/usr/sbin/asmtool -C -l /dev/oracleasm -n OCR3 -s /dev/mapper/storage-ocr3 -a force=yes
oracleasm listdisks
ls -l /dev/oracleasm/
ls -l /dev/oracleasm/disks/
/etc/init.d/oracleasm --help
/etc/init.d/oracleasm listdisks


ALTER DISKGROUP dgroup1 ADD DISK '/devices/diska*';

```
---

### [asmtools: kfod, kfed, amdu](https://www.hhutzler.de/blog/asm-tools-used-by-support-kfod-kfed-amdu-doc-id-1485597-1/)

#### kfod - Kernel Files OSM Disk

```
kfod disk=all
kfod status=true g=OCR
```

#### kfed - Kernel Files metadata EDitor

```
kfed read ORCL:ORC1
kfed read ORCL:ORC1 | grep -P "kfdhdb.hdrsts|kfdhdb.dskname|kfdhdb.grpname|kfdhdb.fgname|kfdhdb.secsize|blksize|driver.provstr|kfdhdb.ausize"
```

#### amdu - ASM Metadata Dump Utility

. Dumps metadata for ASM disks
. Extract the content of ASM files even DG isn't mounted


```
asmcmd lsdg | grep -i ocr
amdu -diskstring 'ORCL:*' -dump 'OCR'
```
