---
title: "aix install zabbix agentd"
layout: post
category: zabbix
---

[zabbix Agent AIX version](https://www.zabbix.com/forum/showthread.php?t=46470)

[How to start hlds on server start up?](http://forums.steampowered.com/forums/archive/index.php/t-98189.html)

### install

+ copy and mv to /usr/local
+ user and group

```
mkgroup zabbix
mkuser pgrp='zabbix' groups='zabbix' zabbix
chown -R zabbix:zabbix /usr/local/zabbix
```

### command

```
su - zabbix -c "/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/conf/zabbix_agentd.conf"
```

### start script

```
mkitab "zabbix:2:once:/usr/local/zabbix/sbin/zabbix_agentd -c /usr/local/zabbix/conf/zabbix_agentd.conf >/dev/null 2>&1"
```

### [error The name "zabbix-db-storage" is already in use by container 1497afc43f4a.](https://github.com/docker/docker/issues/23371)

```
To clear containers:
docker rm -f $(docker ps -a -q)

To clear images:
docker rmi -f $(docker images -a -q)

To clear volumes:
docker volume rm $(docker volume ls -q)
```
