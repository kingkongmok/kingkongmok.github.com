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
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=7 /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh --spare-devices=1 /dev/sdi
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


## [fix mdadm](https://ahelpme.com/linux/recovering-md-array-and-mdadm-cannot-get-array-info-for-dev-md0/)


```
mdadm: Cannot get array info for /dev/md125
```

```
### backup config
mv /etc/mdadm.conf{,.backup20200720}

#RESCAN FOR MD DEVICES WITH MDADM
sudo mdadm --assemble --scan --verbose --force

# ADD THE MISSING PARTITIONS TO YOUR SOFTWARE RAID DEVICES.
sudo mdadm --add /dev/md0 /dev/sdf

# check
mdadm --detail /dev/md0
```

---

### [replace a disk marked as removed](https://www.linuxquestions.org/questions/linux-server-73/mdadm-error-replacing-a-failed-disk-909577/)


```
mdadm -S /dev/md3
mdadm --assemble /dev/md3 /dev/sd[fljed]1 --force
mdadm --manage /dev/md3 --add /dev/sdk1
```

---


### [lvm](https://geekpeek.net/lvm-physical-volume-management/)

```

pvcreate /dev/md0
vgcreate storage /dev/md0



lvcreate -n pridata -L 10GiB storage
lvcreate -n prifra -L 10GiB storage
lvcreate -n priocr1 -L 1GiB storage
lvcreate -n priocr2 -L 1GiB storage
lvcreate -n priocr3 -L 1GiB storage
lvcreate -n stbdata -L 10GiB storage
lvcreate -n stbfra -L 10GiB storage
lvcreate -n stbocr1 -L 10GiB storage
lvcreate -n stbocr1 -L 1GiB storage
lvcreate -n stbocr2 -L 1GiB storage
lvcreate -n stbocr3 -L 1GiB storage
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

<target iqn.2020-03.com.example:storage.pridata>
        backing-store /dev/mapper/storage-pridata
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
    #vendor_id MyCompany Inc.
</target>
<target iqn.2020-03.com.example:storage.prifra>
        backing-store /dev/mapper/storage-prifra
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
    #vendor_id MyCompany Inc.
</target>
<target iqn.2020-03.com.example:storage.priocr1>
        backing-store /dev/mapper/storage-priocr1
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
    #vendor_id MyCompany Inc.
</target>
<target iqn.2020-03.com.example:storage.priocr2>
        backing-store /dev/mapper/storage-priocr2
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
    #vendor_id MyCompany Inc.
</target>
<target iqn.2020-03.com.example:storage.priocr3>
        backing-store /dev/mapper/storage-priocr3
        write-cache on
        initiator-address 192.168.0.1
        initiator-address 192.168.1.1
        initiator-address 192.168.0.2
        initiator-address 192.168.1.2
    #vendor_id MyCompany Inc.
</target>

<target iqn.2020-04.com.example:storage.stbdata>
        backing-store /dev/mapper/storage-stbdata
        write-cache on
        initiator-address 192.168.0.11
        initiator-address 192.168.1.11
        initiator-address 192.168.0.12
        initiator-address 192.168.1.12
    #vendor_id MyCompany Inc.
</target>
<target iqn.2020-04.com.example:storage.stbfra>
        backing-store /dev/mapper/storage-stbfra
        write-cache on
        initiator-address 192.168.0.11
        initiator-address 192.168.1.11
        initiator-address 192.168.0.12
        initiator-address 192.168.1.12
    #vendor_id MyCompany Inc.
</target>
<target iqn.2020-04.com.example:storage.stbocr1>
        backing-store /dev/mapper/storage-stbocr1
        write-cache on
        initiator-address 192.168.0.11
        initiator-address 192.168.1.11
        initiator-address 192.168.0.12
        initiator-address 192.168.1.12
    #vendor_id MyCompany Inc.
</target>
<target iqn.2020-04.com.example:storage.stbocr2>
        backing-store /dev/mapper/storage-stbocr2
        write-cache on
        initiator-address 192.168.0.11
        initiator-address 192.168.1.11
        initiator-address 192.168.0.12
        initiator-address 192.168.1.12
    #vendor_id MyCompany Inc.
</target>
<target iqn.2020-04.com.example:storage.stbocr3>
        backing-store /dev/mapper/storage-stbocr3
        write-cache on
        initiator-address 192.168.0.11
        initiator-address 192.168.1.11
        initiator-address 192.168.0.12
        initiator-address 192.168.1.12
    #vendor_id MyCompany Inc.
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
sudo iscsiadm -m node -P 0
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

for i in `sudo iscsiadm -m node -P 0 | perl -naE 'say $F[1]'`; do iscsiadm -m node -T "$i" -p 192.168.0.150:3260,1 -o delete; done
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
sudo /sbin/multipath -ll|grep -qP "fault|fail|inactive"
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
                wwid      1IET_00030001
                alias     storage-priocr1
        }
        multipath {
                wwid      1IET_00040001
                alias     storage-priocr2
        }
        multipath {
                wwid      1IET_00050001
                alias     storage-priocr3
        }
        multipath {
                wwid      1IET_00020001
                alias     storage-prifra
        }
        multipath {
                wwid      1IET_00010001
                alias     storage-pridata
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


### [ORA-15039 and ORA-15001 while Dropping an ASM disk group](https://www.oraclenext.com/2020/10/ora-15039-and-ora-15001-while-dropping.html)


```
# drop diskgroup
SQL> drop diskgroup fra force  including contents ;

# delete
$>  sudo /usr/sbin/asmtool -D -l /dev/oracleasm -n FRA -s /dev/mapper/storage-prifra -a force=yes

#create 
$> sudo /usr/sbin/asmtool -C -l /dev/oracleasm -n FRA -s /dev/mapper/storage-prifra -a force=yes

# re-scan
$> sudo /etc/init.d/oracleasm scandisks
$> sudo /etc/init.d/oracleasm listdisks

# add diskgroup
SQL> CREATE DISKGROUP FRA  EXTERNAL REDUNDANCY DISK 'ORCL:FRA' ;

# check
SQL> select path,failgroup,mount_status,mode_status,header_status,state from v$asm_disk order by failgroup, path;

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
kfed read ORCL:OCR2
kfed read ORCL:OCR1 | grep -P "kfdhdb.hdrsts|kfdhdb.dskname|kfdhdb.grpname|kfdhdb.fgname|kfdhdb.secsize|blksize|driver.provstr|kfdhdb.ausize"
```

#### amdu - ASM Metadata Dump Utility

. Dumps metadata for ASM disks
. Extract the content of ASM files even DG isn't mounted


```
asmcmd lsdg | grep -i ocr
amdu -diskstring 'ORCL:*' -dump 'OCR'
```

---

### emc


1、存储首先开机，存储的HBA卡向SAN交换机发送RSCN信号，通知HBA卡关联的ZONE成员，表示它已联机。
-- 内核调用HBA卡的驱动和固件共同完成
2、服务器开机后，主机的HBA卡向SAN交换机发送RSCN信号，通知HBA卡关联的ZONE成员，那这个时候在存储里面会看到主机的HBA卡已联机。
3、由于存储中已经配置了映射关系，存储识别到映射关系中的HBA卡联机后会自动映射给主机。
4、主机上的多路径软件默认是自动启动的，多路径软件会根据已有的配置文件对EMC存储映射过来的LUN进行链路聚合，形成/dev/emcpowerxx。
5、通过powermt display dev=all命令查看多路径恢复情况，正常情况下所有路径都是active的。
6、假设无法识别到EMC存储映射过来的LUN，可以执行powermt config重新扫描磁盘，再次查询多路径恢复情况。


如识别不到存储，可使用powermt config重新扫描磁盘

```
powermt config
```

查看链路恢复情况

```
powermt display dev=all
```

重置链路错误数为0

```
powermt restore
```

---

## increase

lvcreate -n pridata1 -L 5GiB storage
lvcreate -n stbdata1 -L 5GiB storage

vim /etc/tgt/targets.conf

... csr stop


sudo /etc/init.d/tgtd force-stop
sudo /etc/init.d/tgtd start


/usr/sbin/asmtool -C -l /dev/oracleasm -n DATA2 -s /dev/mapper/storage-data -a force=yes
kfod disk=all
alter diskgroup DATA add disk 'ORCL:DATA1' rebalance power 10;



---

### emc switch


+ 检查交换机收发异常

```
$> porterrshow
```


+ 清理一下计数器

```
statsclear
slotstatsclear 
```


+ RX Power和TX  Power需要350以上


```
$> sfpshow -all

...
Voltage:     3293.6  mVolts
RX Power:    -2.4    dBm (577.0uW)
TX Power:    -3.1    dBm (487.9 uW)

State transitions: 1
```

```
$> switchshow

switchName:	DS650
switchType:	118.1
switchState:	Online
switchMode:	Native
switchRole:	Principal
switchDomain:	1
switchId:	fffc01
switchWwn:	10:xxxxxxxxxxxxxxxxx
zoning:		ON (DS650)
switchBeacon:	OFF
HIF Mode:	OFF

Index Port Address  Media Speed   State       Proto
==================================================
   0   0   010000   id    N16	  Online      FC  F-Port  50:xxxxxxxxxxxxxxxxxxx
   1   1   010100   id    N16	  No_Light    FC
   2   2   010200   id    N16	  Laser_Flt   FC
   3   3   010300   id    N16	  Online      FC  F-Port  10:xxxxxxxxxxxxxxxxx
   4   4   010400   id    N16	  Online      FC  F-Port  50:xxxxxxxxxxxxxxxxx
   5   5   010500   id    N16	  Online      FC  F-Port  10:xxxxxxxxxxxxxxxxx

```

