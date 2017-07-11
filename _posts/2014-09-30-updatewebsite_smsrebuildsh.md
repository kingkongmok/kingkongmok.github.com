---
layout: post
title: "updateWebsite_smsRebuild.sh 升级脚本"
category: linux
tags: [rsync, smsRebuild, update]
---

`使用方法`
[原文件地址](https://raw.githubusercontent.com/kingkongmok/kingkongmok.github.com/master/bin/updateWebsite_smsRebuild.sh)

`示范`
```
    ./bin/updateWebsite_smsRebuild.sh -t -m sms         #测试升级sms模块和config
    ./bin/updateWebsite_smsRebuild.sh -t -r -m mms      #还原最近一次mms模块和config
    ./bin/updateWebsite_smsRebuild.sh -m mms -w         #删除WEB-INF文档,进行sms模块和config的升级,
    ./bin/updateWebsite_smsRebuild.sh -c -m calendar    #升级calendar模块和配置，并升级本地的定时服务
```

```
kk@ins14 ~/bin $ ./updateWebsite_smsRebuild.sh -t -m sms

#backuping the sms modules.
ssh 172.16.210.52 mkdir -p /home/appBackup/20140930135321
ssh 172.16.210.52 rsync -a /home/appSys/smsRebuild/tomcat_7.0.20_A/webapps/sms /home/appBackup/20140930135321/
ssh 172.16.210.53 mkdir -p /home/appBackup/20140930135321
ssh 172.16.210.53 rsync -a /home/appSys/smsRebuild/tomcat_7.0.20_A/webapps/sms /home/appBackup/20140930135321/
ssh 172.16.210.54 mkdir -p /home/appBackup/20140930135321
ssh 172.16.210.54 rsync -a /home/appSys/smsRebuild/tomcat_7.0.20_A/webapps/sms /home/appBackup/20140930135321/

#updating the sms modules.
rsync -az /home/appSys/smsRebuild/sbin/update/local_sms/sms/ 172.16.210.52:/home/appSys/smsRebuild/tomcat_7.0.20_A/webapps/sms/
rsync -az /home/appSys/smsRebuild/sbin/update/local_sms/sms/ 172.16.210.53:/home/appSys/smsRebuild/tomcat_7.0.20_A/webapps/sms/
rsync -az /home/appSys/smsRebuild/sbin/update/local_sms/sms/ 172.16.210.54:/home/appSys/smsRebuild/tomcat_7.0.20_A/webapps/sms/

#backuping the sms configs.
ssh 172.16.210.52 mkdir -p /home/appBackup/20140930135321
ssh 172.16.210.52 rsync -a /home/appSys/smsRebuild/AppConfig/smscfg /home/appBackup/20140930135321/
ssh 172.16.210.53 mkdir -p /home/appBackup/20140930135321
ssh 172.16.210.53 rsync -a /home/appSys/smsRebuild/AppConfig/smscfg /home/appBackup/20140930135321/
ssh 172.16.210.54 mkdir -p /home/appBackup/20140930135321
ssh 172.16.210.54 rsync -a /home/appSys/smsRebuild/AppConfig/smscfg /home/appBackup/20140930135321/

#updating the sms configs.
rsync -az /home/appSys/smsRebuild/sbin/update/local_sms/smscfg/ 172.16.210.52:/home/appSys/smsRebuild/AppConfig/smscfg/
rsync -az /home/appSys/smsRebuild/sbin/update/local_sms/smscfg/ 172.16.210.53:/home/appSys/smsRebuild/AppConfig/smscfg/
rsync -az /home/appSys/smsRebuild/sbin/update/local_sms/smscfg/ 172.16.210.54:/home/appSys/smsRebuild/AppConfig/smscfg/

#restarting the tomcat.
ssh 172.16.210.52 /home/appSys/smsRebuild/sbin/tomcat_sms_mms_card.sh restart
ssh 172.16.210.53 /home/appSys/smsRebuild/sbin/tomcat_sms_mms_card.sh restart
ssh 172.16.210.54 /home/appSys/smsRebuild/sbin/tomcat_sms_mms_card.sh restart
```


```
kk@ins14 ~/bin $ ./updateWebsite_smsRebuild.sh -t -m calendar -w -c

#backuping the calendar modules.
ssh 172.16.210.52 mkdir -p /home/appBackup/20140930135422
ssh 172.16.210.52 rsync -a /home/appSys/smsRebuild/tomcat_7.0.20_B/webapps/calendar /home/appBackup/20140930135422/
ssh 172.16.210.53 mkdir -p /home/appBackup/20140930135422
ssh 172.16.210.53 rsync -a /home/appSys/smsRebuild/tomcat_7.0.20_B/webapps/calendar /home/appBackup/20140930135422/
ssh 172.16.210.54 mkdir -p /home/appBackup/20140930135422
ssh 172.16.210.54 rsync -a /home/appSys/smsRebuild/tomcat_7.0.20_B/webapps/calendar /home/appBackup/20140930135422/

#updating the calendar WEB-INF folder.
rsync --delete -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendar/WEB-INF 172.16.210.52:/home/appSys/smsRebuild/tomcat_7.0.20_B/webapps/calendar/
rsync --delete -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendar/WEB-INF 172.16.210.53:/home/appSys/smsRebuild/tomcat_7.0.20_B/webapps/calendar/
rsync --delete -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendar/WEB-INF 172.16.210.54:/home/appSys/smsRebuild/tomcat_7.0.20_B/webapps/calendar/

#updating the calendar modules.
rsync -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendar/ 172.16.210.52:/home/appSys/smsRebuild/tomcat_7.0.20_B/webapps/calendar/
rsync -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendar/ 172.16.210.53:/home/appSys/smsRebuild/tomcat_7.0.20_B/webapps/calendar/
rsync -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendar/ 172.16.210.54:/home/appSys/smsRebuild/tomcat_7.0.20_B/webapps/calendar/

#backuping the calendar configs.
ssh 172.16.210.52 mkdir -p /home/appBackup/20140930135422
ssh 172.16.210.52 rsync -a /home/appSys/smsRebuild/AppConfig/calendarcfg /home/appBackup/20140930135422/
ssh 172.16.210.53 mkdir -p /home/appBackup/20140930135422
ssh 172.16.210.53 rsync -a /home/appSys/smsRebuild/AppConfig/calendarcfg /home/appBackup/20140930135422/
ssh 172.16.210.54 mkdir -p /home/appBackup/20140930135422
ssh 172.16.210.54 rsync -a /home/appSys/smsRebuild/AppConfig/calendarcfg /home/appBackup/20140930135422/

#updating the calendar configs.
rsync -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendarcfg/ 172.16.210.52:/home/appSys/smsRebuild/AppConfig/calendarcfg/
rsync -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendarcfg/ 172.16.210.53:/home/appSys/smsRebuild/AppConfig/calendarcfg/
rsync -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendarcfg/ 172.16.210.54:/home/appSys/smsRebuild/AppConfig/calendarcfg/

#restarting the tomcat.
ssh 172.16.210.52 /home/appSys/smsRebuild/sbin/tomcat_disk_bmail_calendar.sh restart
ssh 172.16.210.53 /home/appSys/smsRebuild/sbin/tomcat_disk_bmail_calendar.sh restart
ssh 172.16.210.54 /home/appSys/smsRebuild/sbin/tomcat_disk_bmail_calendar.sh restart

#backuping the local calendar modules.
mkdir -p /home/appBackup/20140930135422
rsync -a /home/appSys/smsRebuild/tomcat_7.0.20/webapps/calendarTimer /home/appBackup/20140930135422/

#updating the local calendar WEB-INF folder.
rsync --delete -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendar/WEB-INF /home/appSys/smsRebuild/tomcat_7.0.20/webapps/calendarTimer/

#updating the local calendar modules.
rsync -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendar/ /home/appSys/smsRebuild/tomcat_7.0.20/webapps/calendarTimer/

#backuping the local calendar configs.
mkdir -p /home/appBackup/20140930135422
rsync -a /home/appSys/smsRebuild/AppConfig/calendarcfg /home/appBackup/20140930135422/

#updating the local calendar configs.
rsync -az /home/appSys/smsRebuild/sbin/update/local_calendar/calendarcfg/ /home/appSys/smsRebuild/AppConfig/calendarcfg/

#restarting the local tomcat.
/home/appSys/smsRebuild/sbin/tomcat_calendarTimer.sh restart
```
