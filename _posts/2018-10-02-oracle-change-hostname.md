---
layout: post
title: "oracle change hostname"
category: linux
tags: [oracle]
---

###  [change hostname](https://dbawiki.wordpress.com/2012/10/24/hostname-change-at-linux-with-oracle-db/)


+ Change the host name properly:

```
/etc/hosts
/etc/sysconfig/network
```

+ Change the hostname in tnsnames.ora and listener.ora:

```
$ORACLE_HOME/network/admin/tnsnames.ora
$ORACLE_HOME/network/admin/listener.ora
```

+ Change the hostname in emd.properties:

```
$ORACLE_HOME/sysman/config/emd.properties
```

+ Reboot
+ Restart the listener manually:

```
lsnrctl stop
lsnrctl start
lsnrctl status
```

+ Recreate EM repository:

```
emca -deconfig dbcontrol db -repos drop
emca -config dbcontrol db -repos create
```
