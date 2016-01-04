---
layout: post
title: "zabbix report"
category: perl
tags: [zabbix, report]
---
{% include JB/setup %}


## zabbix的带图片自动report

---

### [脚本地址](https://github.com/kingkongmok/kingkongmok.github.com/blob/master/linux/var/lib/zabbix/home/NewSendGraph.pl)

+ 这是一个脚本，登录zabbix前端，通过DBI获取mysql上的相应用户信息和screen（id，图片等）信息
+ 通过刚刚获取到的screen的信息，用curl获取图片并用MIME::Lite封装信封
+ 通过DBI获取该 media types 通知的 receipt, 并发邮件
+ 通过邮件，用户获知进今天的screen情况


### zabbix上的设置：

1. 添加media types

    1. name : `Script Summary Report - testScreens.pl: "Screen1:Screen2:Screen3"`
    2. type : `scripts`
    3. stript name : `testScreens`

2. 新建testScreens的screen

3. profile - media 中的 “Script Summary Report - testScreens.pl: "Screen1:Screen2:Screen3"” 设置收信人为需要收件的邮箱地址。这个对应脚本的`select sendto, exec_path from media, media_type where media.mediatypeid=media_type.mediatypeid`

4. 不需要添加Actions，Actions中不需要新添加Triggers，也不需要添加Operations，


### cronie

+ 需要cronie运行该脚本，例如每天凌晨0点运行

