#!/bin/bash
if [ `ps -ef|grep vmmemctl|grep -v grep|wc -l` -gt 0 ]
        then
        SYS=vms
        FS=`df -kP|grep ^/|awk '{sum += $2}{use += $3};END {print sum/1024/1024 "\t" use/1024/1024}'`
        FS_TOTAL=`df -kP|grep ^/|awk '{sum += $2};END {print sum/1024/1024}'`
        FS_USED=`df -kP|grep ^/|awk '{sum += $3};END {print sum/1024/1024}'`
        DISK=`echo $FS_TOTAL`
else
        if [[ `cat /etc/issue|head -1|awk '{print $1}'` = "Ubuntu" ]]
        then
                DISK=`/sbin/fdisk -l|grep "Disk /dev"|grep -v sda|awk '{sum += $5};END {print sum/1024/1024/1024}'`
        else

    sudo /sbin/multipath -ll >/dev/null 2>&1
    if [ $? -eq 0 ]; then
                sudo /sbin/multipath -ll|grep size|awk '{print $1}'|cut -f2 -d= > /tmp/multipath.tmp
                multipath_M=`cat /tmp/multipath.tmp |grep M|cut -f1 -dM|awk '{sum += $1};END {print sum/1024 }'`
                multipath_G=`cat /tmp/multipath.tmp |grep G|cut -f1 -dG|awk '{sum += $1};END {print sum }'`
                multipath_T=`cat /tmp/multipath.tmp |grep T|cut -f1 -dT|awk '{sum += $1};END {print sum*1024 }'`
                rm -rf /tmp/multipath.tmp
                DISK=$[ $multipath_M + $multipath_G + $multipath_T ]
    else 
    DISK=0
    fi    
    fi
        SYS=phy
        FS_TOTAL=`df -kP|grep ^/|grep -v -e /$ -e /mnt$ -e /boot$ -e /home$ -e /tmp$ -e /usr$ -e var$ -e /opt$|awk '{sum += $2};END {print sum/1024/1024}'`
        FS_USED=`df -kP|grep ^/|grep -v -e /$ -e /mnt$ -e /boot$ -e /home$ -e /tmp$ -e /usr$ -e var$ -e /opt$|awk '{sum += $3};END {print sum/1024/1024}'`
fi

if [ `ps -ef|grep ora_lgwr|grep -v grep|wc -l` -gt 0 ]
        then
        sudo su - oracle <<EOF > /tmp/ora_log.tmp
        sqlplus / as sysdba 
        select sum(bytes)/1024/1024/1024 from dba_data_files;
        select sum(bytes)/1024/1024/1024 from dba_segments;
        exit; 
EOF
        ORA_RAW=`cat /tmp/ora_log.tmp |grep -PA 1 "\-----"|sed -n '2p'`
        ORA_DATA=`cat /tmp/ora_log.tmp |grep -PA 1 "\-----"|sed -n '5p'`
        rm -rf /tmp/ora_log.tmp
else
        ORA_RAW=0
        ORA_DATA=0
fi
if [ $DISK = 0 ]
        then
        USED_P=0
else
        USED_P=`echo "scale=2;($FS_USED+$ORA_DATA)*100/$DISK"|bc`
fi
DISK=`echo "scale=2;$DISK/1"|bc`
FS_TOTAL=`echo "scale=2;$FS_TOTAL/1"|bc`
FS_USED=`echo "scale=2;$FS_USED/1"|bc`
ORA_RAW=`echo "scale=2;$ORA_RAW/1"|bc`
ORA_DATA=`echo "scale=2;$ORA_DATA/1"|bc`

echo $USED_P

