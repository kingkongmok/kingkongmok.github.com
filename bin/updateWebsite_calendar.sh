# 先备份
~/sbin/smsRebuild_update.sh calendar backup
~/sbin/smsRebuild_update_conf.sh conf1 backup

# 删除旧配置
ssh 172.16.210.52 'rm -rf ~/disk.bmail.calendar/calendar/WEB-INF/*'
ssh 172.16.210.53 'rm -rf ~/disk.bmail.calendar/calendar/WEB-INF/*'
ssh 172.16.210.54 'rm -rf ~/disk.bmail.calendar/calendar/WEB-INF/*'
rm -rf ~/calendarTimer/calendarTimer/WEB-INF/

# 开始更新
~/sbin/smsRebuild_update.sh calendar update_calendar
~/sbin/smsRebuild_update_conf.sh conf1 update_conf1
cp -af ~/calendarTimer/calendarTimer/* ~/calendarTimer/calendarTimer/
cp -f sbin/update/local_conf1/calendarcfg/mqmessage.xml AppConfig/calendarcfg/mqmessage.xml

# 先kill掉相应进程，然后重启相应tomcat，kill过程省略
ssh 172.16.210.52 '~/sbin/tomcat_disk_bmail_calendar.sh restart'
ssh 172.16.210.53 '~/sbin/tomcat_disk_bmail_calendar.sh restart'
ssh 172.16.210.54 '~/sbin/tomcat_disk_bmail_calendar.sh restart'

# 先kill掉相应进程，然后重启相应tomcat，kill过程省略
~/sbin/tomcat_calendarTimer.sh restart

# 异常处理, 找到还原点
~/sbin/smsRebuild_update.sh calendar resume 201409182356
#~/sbin/smsRebuild_update_conf.sh conf1 resule 201409182357

for i in 2 3 4; do ssh 172.16.210.5$i 'cp -af /home/appBackup/201409181554/AppConfig/calendarcfg/mqmessage.xml ~/AppConfig/calendarcfg/mqmessage.xml'; done

for i in 2 3 4; do ssh 172.16.210.5$i '~/sbin/tomcat_disk_bmail_calendar.sh restart' ; done

~/sbin/tomcat_calendarTimer.sh restart
rsync -au /tmp/testdownload/rh-calendar-1.1.5.jar ~/calendarTimer/calendarTimer/WEB-INF/lib/rh-calendar-1.1.5.jar
rsync -au /tmp/testdownload/mqmessage.xml ~/AppConfig/calendarcfg/mqmessage.xml 
~/sbin/tomcat_calendarTimer.sh restart

for i in 52 53 54 ; do rsync -aunvh /tmp/testdownload/rh-calendar-1.1.5.jar 172.16.210.${i}:~/disk.bmail.calendar/calendar/WEB-INF/lib/rh-calendar-1.1.5.jar; done
for i in 52 53 54 ; do rsync -aunvh /tmp/testdownload/mqmessage.xml 172.16.210.${i}:~/AppConfig/calendarcfg/mqmessage.xml ; done
for i in 52 53 54 ; do ssh 172.16.210.${i} ~/sbin/tomcat_disk_bmail_calendar.sh restart ; done

# restore

rsync -au ~/backup_files/2014-09-21/calendarTimer/WEB-INF/lib/rh-calendar-1.1.5.jar ~/calendarTimer/calendarTimer/WEB-INF/lib/rh-calendar-1.1.5.jar
rsync -au ~/backup_files/2014-09-21/calendarcfg/mqmessage.xml ~/AppConfig/calendarcfg/mqmessage.xml 
~/sbin/tomcat_calendarTimer.sh restart

for i in 52 53 54 ; do rsync -aunvh ~/backup_files/2014-09-21/calendarTimer/WEB-INF/lib/rh-calendar-1.1.5.jar 172.16.210.${i}:~/disk.bmail.calendar/calendar/WEB-INF/lib/rh-calendar-1.1.5.jar; done
for i in 52 53 54 ; do rsync -aunvh ~/backup_files/2014-09-21/calendarcfg/mqmessage.xml 172.16.210.${i}:~/AppConfig/calendarcfg/mqmessage.xml ; done
for i in 52 53 54 ; do ssh 172.16.210.${i} ~/sbin/tomcat_disk_bmail_calendar.sh restart ; done

~/backup_files/2014-09-21/calendarcfg/mqmessage.xml 
~/backup_files/2014-09-21/calendarTimer/WEB-INF/lib/rh-calendar-1.1.5.jar
