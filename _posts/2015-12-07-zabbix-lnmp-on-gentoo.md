---
layout: post
title: "zabbix and lnmp on gentoo"
category: linux
tags: [php, zabbix]
---

--- 

## [php](https://wiki.gentoo.org/wiki/PHP)

#### 设置use

/etc/portage/make.conf

```
USE="php"
```

---

#### php.ini use production 

> 设置php.ini使用production版本，当然可/usr/share/doc/php-5.6.14/php.ini-production.bz2找到 

/etc/portage/make.conf

```
PHP_INI_VERSION="production"
```

---


* package.use ，这个是配合zabbix使用的

```
/etc/portage/package.use:dev-lang/php gd bcmath sockets xmlwriter xmlreader fpm cgi curl imap mysql mysqli pdo zip json xcache apc zlib zip truetype -apache2 
```

---

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

---

## nginx


---

#### make.conf

* 这里只需要fastcgi

```
$ grep nginx  -iIr /etc/portage/
/etc/portage/package.use:www-servers/nginx NGINX_MODULES_HTTP="gunzip headers_more stub_status upstream_check"
/etc/portage/make.conf:NGINX_MODULES_HTTP="access autoindex browser charset empty_gif fastcgi flv geoip gzip map proxy rewrite stub_status upstream_ip_hash upload_progress"
```

---

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

---

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

---

## mysql

#### make.conf


```
$ grep mysql /etc/portage/ -iIr
/etc/portage/package.use:dev-lang/php gd bcmath sockets xmlwriter xmlreader fpm cgi curl imap mysql mysqli pdo zip json xcache apc zlib zip truetype -apache2
```

---

###     Database creation scripts


+ A Zabbix database must be created during the installation of Zabbix server or proxy.
+ [官方说明](https://www.zabbix.com/documentation/2.0/manual/appendix/install/db_scripts)
+ [example](http://blog.zwiegnet.com/linux-server/configure-zabbix-proxy/)

1. for zabbix-server

        shell> mysql -u<username> -p<password>
        mysql> create database zabbix character set utf8 collate utf8_bin;
        mysql> quit;
        shell> mysql -u<username> -p<password> zabbix < database/mysql/schema.sql
        # stop here if you are creating database for Zabbix proxy
        shell> mysql -u<username> -p<password> zabbix < database/mysql/images.sql
        shell> mysql -u<username> -p<password> zabbix < database/mysql/data.sql

2. for zabbix-proxy

        shell> mysql -u<username> -p<password>
        mysql> create database zabbix_proxy character set utf8;
        mysql> grant all privileges on zabbix_proxy.* to zabbix@localhost identified by 'zabbixpassword';
        mysql> quit;
        shell> mysql -uzabbix -p zabbix_proxy < database/mysql/schema.sql
        # stop here if you are creating database for Zabbix proxy

---

## zabbix

--- 

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

---

## zabbix_agentd

---

#### [ host not found ](https://www.zabbix.com/forum/showthread.php?t=16915)

* zabbix_agentd.log 

```
No active checks on server: host [test.linux.local] not found
```

* set Hostname at zabbix_agentd.conf as the same in server

---

### 允许运行sudo命令：

* 这里需要sudoers添加非tty输入支持，并设置NOPASSWD

```
Defaults:zabbix !requiretty
Cmnd_Alias ZABBIX_CMD = /sbin/fuser, /usr/sbin/lsof, /usr/sbin/dmidecode, /sbin/mii-tool, /sbin/ethtool, /usr/bin/ipmitool, /usr/sbin/iptstate, /usr/bin/ocaudit, /sbin/iptables
zabbix   ALL = (other_user)  NOPASSWD: ALL
zabbix   ALL = (root)        NOPASSWD: ZABBIX_CMD
```

---

### /etc/passwd 

> 这里需要设置用户nologin

```
zabbix:x:1001:1001::/var/lib/zabbix/home:/bin/nologin
```

---

### 使用自定义命令

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

---

#### zabbix_agentd command test on agentd site

```
$ zabbix_agentd -p | grep 'system.uptime'
system.uptime                                 [u|11624]
```

---

####  zabbix_get on server side

```
$ zabbix_get -s agent.localdomain  -k "system.uptime"
11685
```

---

#### TEMPLATE

+ 一般首字母大写，例如 Template Storage
+ Group 设置属于 Templates 即可

#### Application

+ 一般简单的文件夹性质，也是首字母大写, 简单的归纳用途，例如新建一个 Processes的 Applicatioin.

#### Item

+ 这里就需要对应zabbix_agentd的自定义变量， 可以先用测试是否能得到需要的数值，
+ 例如，我先测试能否得到test.tcpsock

```
$ zabbix_get  -s 127.0.0.1 -p 10050 -k test.tcpsock
144

$ sudo grep test.tcpsock /etc/zabbix/zabbix_agentd.conf
UserParameter=test.tcpsock,ss -s | perl -nae 'print $F[1] if /^TCP:/'
```

### Trigger

+ 那么 ，在刚刚的Application下添加Item， type 为 zabbix agent, Application为刚刚的Processes
+ 格式：

```
{<Template>:<key>.<function>}<operator><constant>
或者
{<Host>:<key>.<function>}<operator><constant>
```

例如

```
{Template App Zabbix Agent:agent.hostname.diff(0)}>0
{Template App Zabbix Agent:agent.ping.nodata(5m)}=1
{Host_gentoo:test.tcpsock.last(0)}>30
```

### [Scenarios](https://www.zabbix.com/documentation/1.8/manual/web_monitoring)

+ scenario相当于curl的脚本，用于检测Web服务器监控情况，可以定义访问的protocal， UA, HTTP proxy等浏览器信息
+ step定影URL，post内容等
    

---

### email media

*   SMTP server :   FQDN
*   SMTP helo   :   FQDN
*   SMTP email  :   zabbix@FQDN

*   dns反向解析( smtp :25 )


### 多次邮件报警

#### [Escalation examples](https://www.zabbix.com/documentation/2.0/manual/config/notifications/action/escalations#escalation_examples)

* Actions -> Operations
* From 1 和 To 0 Step duration 0 是指 从第一次到到无数次, 默认间隔1分钟。这样可以发给SA。
* From 5 To 5 duration 0 , 是指第5次开始给人发邮件， 适用于manager

### 邮件中添加ip地址和时间：

> **Actions** -> **Action**

```
On: {DATE} {TIME} At: {IPADDRESS}
```
--- 

### [Triggers for Web scenarios](https://www.zabbix.com/forum/archive/index.php/t-43349.html)

#### item key for failed step 

* [推荐](https://www.zabbix.com/documentation/2.2/manual/web_monitoring/items)

*  step 3 出错的邮件报错：

```
1. Failed step of scenario "Scenario". (Host:web.test.fail[steps]): 3
```

```
{Template name:web.test.fail[Scenario name].last(0)}#0
```

#### item key for fail info change

* 检测最后scenario的steps结果是否非0, 但这个恢复后都会problem，不建议使用

```
{TEMPLATE name:web.test.fail[Scenario name].change(0)}#0 
```

---

### Template App MySQL

+ 根据[论坛](https://www.zabbix.com/forum/showthread.php?t=41659)提示，添加相应命令。

> 注意HOME的意思是my.cnf所在路径.

1. 各种**mysql.status**命令
    1. 修改my.cnf, 添加默认用户密码

        ```
        my.conf

        [client]
        user=nobody
        ```

        ```
        mysql>

        CREATE USER 'nobody'@'localhost' ;
        ```


    2. mysql命令

        ```
        UserParameter=mysql.status[*],echo "show global status where Variable_name='$1';" | HOME=/etc/mysql mysql -uUSERNAME -N | awk '{print $$2}'
        ```

        ```
        Warning: Using a password on the command line interface can be insecure.
        ```



2. **mysql.ping**

    ```
    UserParameter=mysql.ping,HOME=/etc/mysql mysqladmin ping | grep -c alive
    ```

3. **mysql.version**

    ```
    UserParameter=mysql.version,mysql -V
    ```

---

## zabbix-proxy

+ 以下测试，在原有server -> agentd的基础上，添加proxy。server通过proxy(active)来访问agentd
    1. 在proxy passive的情况下，agentd无法通过proxy来上传，不能使用**zabbix_sender**进行上传
    2. 在active的情况下，agentd可以上传到proxy，并由proxy推送到server。
+ 创建proxy和server的db信息，注意proxy和server别用同一个库，真实使用中，proxy应该独立建库以cache

1. proxy上，如上述创建mysql的表结构

2. zabbix->administration->DM->create
    1. Proxy name: proxy的表示，需要和proxy中的**zabbix_proxy.conf** 字段的 **Hostname**匹配
    2. Proxy mode: 这个可以选择active

3. zabbix->configuration->hosts->host
    1. Host name: 这里的名称依然需要对应 **zabbix-agentd.con** 中的 **Hostname**
    2. Monitored by proxy： 这个设置proxy的 **Hostname**
    3. Status: monitored

4. zabbix_proxy.conf

        ProxyMode=0
        Server=127.0.0.1
        ServerPort=10051
        Hostname=ins14
        ListenPort=10052
        SourceIP=127.0.0.1
        LogFile=/var/log/zabbix/zabbix_proxy.log
        LogFileSize=128
        PidFile=/run/zabbix/zabbix_proxy.pid
        DBHost=localhost
        DBName=zabbix_proxy
        DBUser=zabbix
        DBPassword=zabbixpassword

5.zabbix_server.conf

        ListenPort=10051
        LogFile=/var/log/zabbix/zabbix_server.log
        LogFileSize=128
        PidFile=/run/zabbix/zabbix_server.pid
        DBHost=127.0.0.1
        DBName=zabbix
        DBUser=zabbix
        DBPassword=zabbixpassword
        DBSocket=/tmp/mysql.sock
        DBPort=3306
        AlertScriptsPath=/var/lib/zabbix/home
        ExternalScripts=/var/lib/zabbix/externalscripts

6. zabbix_agentd.conf

        PidFile=/run/zabbix/zabbix_agentd.pid
        LogFile=/var/log/zabbix/zabbix_agentd.log
        LogFileSize=128
        SourceIP=127.0.0.1
        EnableRemoteCommands=1
        Server=127.0.0.1
        ListenIP=127.0.0.1
        ServerActive=127.0.0.1:10052
        Hostname=gentoo
        UnsafeUserParameters=1
        UserParameter=test.tcpsock,ss -s | perl -nae 'print $F[1] if /^TCP:/'
        UserParameter=test.df,df
        #危险，待细化,尽量减少*的使用
        UserParameter=mysql.status[*],echo "show global status where Variable_name='$1';" | HOME=/etc/mysql mysql -N | awk '{print $$2}'
        UserParameter=mysql.ping,HOME=/etc/mysql mysqladmin ping | grep -c alive
        UserParameter=mysql.version,mysql -V

---

## zabbix node

1. 需要修改数据库，所以先备份zabbix-server所在的zabbix库

        mysql -uzabbix -p zabbix | gzip > ~/db_zabbix.sql.gz

2. 使用[引用](https://www.zabbix.com/documentation/2.0/manual/distributed_monitoring/nodes)方法进行转换，注意只能做一次否则会破坏数据结构。

        cd bin
        ./zabbix_server -n 1 -c /usr/local/etc/zabbix_server.conf

    1. ***zabbix node conversion failed***

    这个情况需要delete掉以下两个表**events**和**autoreg_host**; 

    2. 需要停止 phpd，否则以下报错：

            Dropping foreign keys ..........................done.
            Converting tables .....................[12807]: 
            Error: [Z3005] query failed: [1114] The table 'history_uint' is full 
            [update history_uint set itemid=itemid+100100000000000 where itemid>0]
            .................................Conversion failed.

3. configuration:

    1. zabbix_server.conf

            NodeID=1
            ListenPort=10051
            LogFile=/var/log/zabbix/zabbix_server.log
            LogFileSize=128
            PidFile=/run/zabbix/zabbix_server.pid
            DBHost=127.0.0.1
            DBName=zabbix
            DBUser=zabbix
            DBPassword=zabbixpassword
            DBSocket=/tmp/mysql.sock
            DBPort=3306
            AlertScriptsPath=/var/lib/zabbix/home
            ExternalScripts=/var/lib/zabbix/externalscripts

    2. zabbix_proxy.conf 

            ProxyMode=0
            Server=127.0.0.1
            ServerPort=10051
            Hostname=proxy
            ListenPort=10052
            SourceIP=127.0.0.1
            LogFile=/var/log/zabbix/zabbix_proxy.log
            LogFileSize=128
            PidFile=/run/zabbix/zabbix_proxy.pid
            DBHost=localhost
            DBName=zabbix_proxy
            DBUser=zabbix
            DBPassword=zabbixpassword

    3. zabbix_agentd.conf

            PidFile=/run/zabbix/zabbix_agentd.pid
            LogFile=/var/log/zabbix/zabbix_agentd.log
            LogFileSize=128
            SourceIP=127.0.0.1
            EnableRemoteCommands=1
            Server=127.0.0.1
            ListenIP=127.0.0.1
            ServerActive=127.0.0.1:10052
            Hostname=agentd
            UnsafeUserParameters=1
            UserParameter=test.tcpsock,ss -s | perl -nae 'print $F[1] if /^TCP:/'
            UserParameter=test.df,df
            UserParameter=mysql.status[*],echo "show global status where Variable_name='$1';" | HOME=/etc/mysql mysql -N | awk '{print $$2}'
            UserParameter=mysql.ping,HOME=/etc/mysql mysqladmin ping | grep -c alive
            UserParameter=mysql.version,mysql -V

4. [Front-end configuration](https://www.zabbix.com/documentation/2.2/manual/distributed_monitoring/nodes) 

    1. master : host设置为 **guangzhou: proxy: agentd** , 依次为Node name， Proxy name，Host name。
