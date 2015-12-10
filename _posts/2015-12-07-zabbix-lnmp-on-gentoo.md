---
layout: post
title: "zabbix and lnmp on gentoo"
category: linux
tags: [php, zabbix]
---
{% include JB/setup %}

***** 

## [php](https://wiki.gentoo.org/wiki/PHP)

#### 设置use

/etc/portage/make.conf

```
USE="php"
```

*****

#### php.ini use production 

设置php.ini使用production版本，当然可/usr/share/doc/php-5.6.14/php.ini-production.bz2找到

/etc/portage/make.conf

```
PHP_INI_VERSION="production"
```

*****


* package.use ，这个是配合zabbix使用的

```
/etc/portage/package.use:dev-lang/php gd bcmath sockets xmlwriter xmlreader fpm cgi curl imap mysql mysqli pdo zip json xcache apc zlib zip truetype -apache2 
```

*****

```
$ sudo systemctl status php-fpm@5.6.service
● php-fpm@5.6.service - The PHP FastCGI Process Manager
   Loaded: loaded (/usr/lib64/systemd/system/php-fpm@5.6.service; disabled; vendor preset: enabled)
   Active: active (running) since Mon 2015-12-07 15:02:48 CST; 28min ago
 Main PID: 9422 (php-fpm)
   Status: "Processes active: 0, idle: 20, Requests: 2, slow: 0, Traffic: 0req/sec"
   CGroup: /system.slice/system-php\x2dfpm.slice/php-fpm@5.6.service
           ├─9422 php-fpm: master process (/etc/php/fpm-php5.6/php-fpm.conf)
           ├─9423 php-fpm: pool www
           ├─9424 php-fpm: pool www
           ├─9425 php-fpm: pool www
           ├─9426 php-fpm: pool www
           ├─9427 php-fpm: pool www
           ├─9428 php-fpm: pool www
           ├─9429 php-fpm: pool www
           ├─9430 php-fpm: pool www
           ├─9431 php-fpm: pool www
           ├─9432 php-fpm: pool www
           ├─9433 php-fpm: pool www
           ├─9434 php-fpm: pool www
           ├─9435 php-fpm: pool www
           ├─9436 php-fpm: pool www
           ├─9437 php-fpm: pool www
           ├─9438 php-fpm: pool www
           ├─9439 php-fpm: pool www
           ├─9440 php-fpm: pool www
           ├─9441 php-fpm: pool www
           └─9442 php-fpm: pool www

Dec 07 15:02:48 ins14 php-fpm-launcher[9422]: [07-Dec-2015 15:02:48] NOTICE: [pool www] pm.start_servers is not set...o 20.
Dec 07 15:02:48 ins14 systemd[1]: Started The PHP FastCGI Process Manager.
Hint: Some lines were ellipsized, use -l to show in full.
```

*****

## nginx


*****

#### make.conf

* 这里只需要fastcgi

```
$ grep nginx  -iIr /etc/portage/
/etc/portage/package.use:www-servers/nginx NGINX_MODULES_HTTP="gunzip headers_more stub_status upstream_check"
/etc/portage/make.conf:NGINX_MODULES_HTTP="access autoindex browser charset empty_gif fastcgi flv geoip gzip map proxy rewrite stub_status upstream_ip_hash upload_progress"
```

*****

#### nginx.conf

```
                location ~ \.php$ {
                    # Test for non-existent scripts or throw a 404 error
                    # Without this line, nginx will blindly send any request ending in .php to php-fpm
                    try_files $uri =404;
                    include /etc/nginx/fastcgi.conf;
                    fastcgi_pass 127.0.0.1:9000;  ## Make sure the socket corresponds with PHP-FPM conf file
                }
```

*****

#### systemd status

```
$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib64/systemd/system/nginx.service; disabled; vendor preset: enabled)
   Active: active (running) since Mon 2015-12-07 15:36:47 CST; 2s ago
  Process: 10899 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 10898 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
 Main PID: 10904 (nginx)
   CGroup: /system.slice/nginx.service
           ├─10904 nginx: master process /usr/sbin/nginx
           └─10905 nginx: worker process

Dec 07 15:36:47 ins14 nginx[10898]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Dec 07 15:36:47 ins14 nginx[10898]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Dec 07 15:36:47 ins14 systemd[1]: Failed to read PID from file /run/nginx.pid: Invalid argument
Dec 07 15:36:47 ins14 systemd[1]: Started The nginx HTTP and reverse proxy server.
```

*****

## mysql

#### make.conf


```
$ grep mysql /etc/portage/ -iIr
/etc/portage/package.use:dev-lang/php gd bcmath sockets xmlwriter xmlreader fpm cgi curl imap mysql mysqli pdo zip json xcache apc zlib zip truetype -apache2
```

*****

## zabbix

***** 

#### make.conf package.use

```
# required by dev-lang/php-5.6.14::gentoo
# required by php (argument)
>=app-eselect/eselect-php-0.7.1-r4 fpm
net-analyzer/zabbix agent curl frontend libxml2 mysql proxy server snmp ssh xmpp
# required by net-analyzer/zabbix-2.2.5::gentoo[frontend]
# required by @selected
# required by @world (argument)
>=dev-lang/php-5.6.14 sysvipc
```

*****

## zabbix_agentd

*****

#### [ host not found ](https://www.zabbix.com/forum/showthread.php?t=16915)

* zabbix_agentd.log 

```
No active checks on server: host [test.linux.local] not found
```

* set Hostname at zabbix_agentd.conf as the same in server

*****

#### sudo config for zabbix

```
zabbix ALL=(ALL) NOPASSWD:/sbin/fdisk -l,/sbin/multipath -ll,/bin/su - oracle,/opt/zabbix/bin/
```

*****

#### UserParameter

```
### Option: UserParameter
#       User-defined parameter to monitor. There can be several user-defined parameters.
#       Format: UserParameter=<key>,<shell command>
#       See 'zabbix_agentd' directory for examples.
#
# Mandatory: no
# Default:
#UserParameter=
### This is For Disk/IO
UserParameter=custom.vfs.dev.discovery,/opt/zabbix/bin/discoverDisks.pl
UserParameter=custom.vfs.dev.read.ops[*],cat /proc/diskstats | egrep $1 | head -1 | awk '{print $$4}'
UserParameter=custom.vfs.dev.read.sectors[*],cat /proc/diskstats | egrep $1 | head -1 | awk '{print $$6}'
UserParameter=custom.vfs.dev.read.ms[*],cat /proc/diskstats | egrep $1 | head -1 | awk '{print $$7}'
UserParameter=custom.vfs.dev.write.ops[*],cat /proc/diskstats | egrep $1 | head -1 | awk '{print $$8}'
UserParameter=custom.vfs.dev.write.sectors[*],cat /proc/diskstats | egrep $1 | head -1 | awk '{print $$10}'
UserParameter=custom.vfs.dev.write.ms[*],cat /proc/diskstats | egrep $1 | head -1 | awk '{print $$11}'
UserParameter=custom.vfs.dev.io.active[*],cat /proc/diskstats | egrep $1 | head -1 | awk '{print $$12}'
UserParameter=custom.vfs.dev.io.ms[*],cat /proc/diskstats | egrep $1 | head -1 | awk '{print $$13}'

### This is For Connetcion
#TCP connection
UserParameter=net.conn.tcp.total,netstat -nt | grep ^tcp | wc -l

#$1=IP2[TIME_WAIT|ESTABLISHED]
UserParameter=net.conn.tcp[*],netstat -nt | grep "$1" | grep ^tcp | grep "$2" | wc -l


###number of total open files
UserParameter=lsof.total,lsof -n|wc -l

#number of open files for special processes
UserParameter=lsof.process[*],lsof -p $1 |wc -l

### For service status
UserParameter=service.status[*],/etc/init.d/$1 status > /dev/null 2>&1; echo $?

### For Processs
UserParameter=user.process[*],ps -ef|grep "$1" | wc -l
UserParameter=wc[*],grep -c "$2" $1
UserParameter=diskpused,/opt/zabbix/bin/diskpused.sh
UserParameter=disktotal,/opt/zabbix/bin/disktotal.sh
UserParameter=mulpcheck,/opt/zabbix/bin/multipathcheck.sh
UserParameter=net.in.total,/opt/zabbix/bin/neticoming.sh
UserParameter=net.out.total,/opt/zabbix/bin/netouting.sh
UserParameter=iowait,iostat -x 1 2 |awk 'BEGIN{RS=""}NR==5'|grep -vE d0p|awk -F' ' '{print $NF}'|grep -e \\.|awk '{if($1+0.01> max)max=$1}END{print max}'
```
