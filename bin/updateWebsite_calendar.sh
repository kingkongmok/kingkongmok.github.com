# 先备份
~/sbin/smsRebuild_update.sh calendar backup
~/sbin/smsRebuild_update_conf.sh conf1 backup

# 删除旧配置
ssh 172.16.210.52 'rm -rf ~/disk.bmail.calendar/calendar/WEB-INF/*'
ssh 172.16.210.53 'rm -rf ~/disk.bmail.calendar/calendar/WEB-INF/*'
ssh 172.16.210.54 'rm -rf ~/disk.bmail.calendar/calendar/WEB-INF/*'

# 开始更新
~/sbin/smsRebuild_update.sh calendar update_calendar
~/sbin/smsRebuild_update_conf.sh conf1 update_conf1

# 先kill掉相应进程，然后重启相应tomcat，kill过程省略
ssh 172.16.210.52 '~/sbin/tomcat_disk_bmail_calendar.sh restart'
ssh 172.16.210.53 '~/sbin/tomcat_disk_bmail_calendar.sh restart'
ssh 172.16.210.54 '~/sbin/tomcat_disk_bmail_calendar.sh restart'

# 先kill掉相应进程，然后重启相应tomcat，kill过程省略
~/sbin/tomcat_calendarTimer.sh restart

# 异常处理, 找到还原点
~/sbin/smsRebuild_update.sh calendar resume xxxxxxxx
ssh 172.16.210.52 'cp -af /home/appBackup/201409181554/AppConfig/calendarcfg/mqmessage.xml ~/AppConfig/calendarcfg/mqmessage.xml'
ssh 172.16.210.53 'cp -af /home/appBackup/201409181554/AppConfig/calendarcfg/mqmessage.xml ~/AppConfig/calendarcfg/mqmessage.xml'
ssh 172.16.210.54 'cp -af /home/appBackup/201409181554/AppConfig/calendarcfg/mqmessage.xml ~/AppConfig/calendarcfg/mqmessage.xml'
ssh 172.16.210.52 '~/sbin/tomcat_disk_bmail_calendar.sh restart'
ssh 172.16.210.53 '~/sbin/tomcat_disk_bmail_calendar.sh restart'
ssh 172.16.210.54 '~/sbin/tomcat_disk_bmail_calendar.sh restart'
~/sbin/tomcat_calendarTimer.sh restart
