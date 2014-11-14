---
layout: post
title: "monitor logs increase and warning 日志监控增长情况"
category: linux
tags: [logs, increase, monitor, logrotate]
---
{% include JB/setup %}

**监控日志的增长量**

## 脚本思路

* 记录各个业务关键log，当出现log对比往日相同时段出现过多过少的时候报警
* 可以设置报警人手机和邮箱，并设置对比往日阀值
* 记录文件可以回滚并自行删除

### 前期脚本存放

```
$ mkdir ~/bin/ ~/count
$ cp countLogSize.sh ~/bin/
$ cp count_logrotate.conf ~/bin/
```

### 找你需要监控的log文件，让cronie帮你将这些文件生成size文件。

观察需要监控的accesslog, 这里我们对 ***/var/log*** 进行处理， 这个步骤后添加到cronie，让其自动执行 ***countLogSize.sh*** ，让其分析各log文件。

```
$ nice sudo  find -L /var/log -type f -name \*log -mtime -1 | perl -MFile::Basename -lane 'printf "%i-59/10 * * * * ~/bin/countLogSize.sh -i %s -o ~/count/%s.size >> ~/count/crontab.log 2>&1\n",$i++ % 10, $_, basename$_'

0-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/kern.log -o ~/count/kern.log.size >> ~/count/crontab.log 2>&1
1-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/cron.log -o ~/count/cron.log.size >> ~/count/crontab.log 2>&1
2-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/lastlog -o ~/count/lastlog.size >> ~/count/crontab.log 2>&1
3-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/tallylog -o ~/count/tallylog.size >> ~/count/crontab.log 2>&1
4-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/kk/139_curl.log -o ~/count/139_curl.log.size >> ~/count/crontab.log 2>&1
5-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/nginx/localhost.access_log -o ~/count/localhost.access_log.size >> ~/count/crontab.log 2>&1
6-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/nginx/error_log -o ~/count/error_log.size >> ~/count/crontab.log 2>&1
7-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/nginx/localhost.error_log -o ~/count/localhost.error_log.size >> ~/count/crontab.log 2>&1
8-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/user.log -o ~/count/user.log.size >> ~/count/crontab.log 2>&1
9-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/mail.log -o ~/count/mail.log.size >> ~/count/crontab.log 2>&1
0-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/daemon.log -o ~/count/daemon.log.size >> ~/count/crontab.log 2>&1
1-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/auth.log -o ~/count/auth.log.size >> ~/count/crontab.log 2>&1
2-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/rc.log -o ~/count/rc.log.size >> ~/count/crontab.log 2>&1
3-59/10 * * * * ~/bin/countLogSize.sh -i /var/log/debug.log -o ~/count/debug.log.size >> ~/count/crontab.log 2>&1
```

## 生成logrotate.conf文件，让logrotate 处理 ~/count/ 的临时文件

```
$ cat > ~/bin/count_logrotate.conf << EOF
/home/kk/count/*size
/home/kk/count/*log
{
    size 1
    rotate 14
    missingok
    copytruncate
    notifempty
}
EOF
```

并添加到crontab执行


```
21 18   * * *   nice /usr/sbin/logrotate -s ~/count/logrotate.stat.log -f ~/bin/count_logrotate.conf
```

通过检查~/count/*size来判断是否执行成功

```
$ head ~/count/access.log.size

2014-11-05 18:32:01 4318082190  31870775
2014-11-05 18:42:01 4346143636  28061446
2014-11-05 18:52:01 4372117654  25974018
```

* 第一项运行countLogSize.sh的时间
* 第二项是accesslog的大小字节数
* 第三项是和上次比较（10分钟前）增加的字节大小数

## 报警

修改crontab里的`~/bin/countLogSize.sh` 添加 `-w` 参数来执行报警。

```
0-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/kern.log -o ~/count/kern.log.size >> ~/count/crontab.log 2>&1
1-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/cron.log -o ~/count/cron.log.size >> ~/count/crontab.log 2>&1
2-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/lastlog -o ~/count/lastlog.size >> ~/count/crontab.log 2>&1
3-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/tallylog -o ~/count/tallylog.size >> ~/count/crontab.log 2>&1
4-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/kk/139_curl.log -o ~/count/139_curl.log.size >> ~/count/crontab.log 2>&1
5-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/nginx/localhost.access_log -o ~/count/localhost.access_log.size >> ~/count/crontab.log 2>&1
6-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/nginx/error_log -o ~/count/error_log.size >> ~/count/crontab.log 2>&1
7-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/nginx/localhost.error_log -o ~/count/localhost.error_log.size >> ~/count/crontab.log 2>&1
8-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/user.log -o ~/count/user.log.size >> ~/count/crontab.log 2>&1
9-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/mail.log -o ~/count/mail.log.size >> ~/count/crontab.log 2>&1
0-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/daemon.log -o ~/count/daemon.log.size >> ~/count/crontab.log 2>&1
1-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/auth.log -o ~/count/auth.log.size >> ~/count/crontab.log 2>&1
2-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/rc.log -o ~/count/rc.log.size >> ~/count/crontab.log 2>&1
3-59/10 * * * * ~/bin/countLogSize.sh -w -i /var/log/debug.log -o ~/count/debug.log.size >> ~/count/crontab.log 2>&1
```

隔天后观察~/count/crontab.log，看有RATE字样，该值为当前增长量和过往增长量的比值，我们通过-n 和 -m参数进行报警值的设置

```
1-59/10 * * * * ~/bin/countLogSize.sh -w -m 2.5 -n 0.3 -i /var/log/access.log -o ~/count/access.log.size >> ~/count/crontab.log 2>&1
```

当然也可以通过设置 `bin/countLogSize.sh` 的 `RATE_THRESHOLD` 来控制默认报警值

```bash
$ grep RATE_THRESHOLD= ~/bin/countLogSize.sh 

MIN_RATE_THRESHOLD="0.5"
MAX_RATE_THRESHOLD="2"
```
