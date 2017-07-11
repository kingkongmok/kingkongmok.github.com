---
layout: post
title: "mysql backup "
category: linux
tags: [mysql, backup]
---

## 备份

```
# --add-drop-database用于--all-databases or --databases的操作。单数据库无效。
nice /usr/local/mysql/bin/mysqldump -ukk -p igbsurvey | gzip > igbsurvey.sql.gz
```

## 还原

```
nice zcat igbsurvey.sql.gz | mysql -uroot -p igbsurvey
```

--- 

## [不重启的情况下备份](http://lizhenliang.blog.51cto.com/7876557/1669829)

```
# mysqldump -uroot -p123 --routines --single_transaction --master-data=2
--databases weibo > weibo.sql
```

**--routines**：导出存储过程和函数

**--single_transaction**：导出开始时设置事务隔离状态，并使用一致性快照开始事务，然后unlock tables;而lock-tables是锁住一张表不能写操作，直到dump完毕。

**--master-data**：默认等于1，将dump起始（change master to）binlog点和pos值写到结果中，等于2是将change master to写到结果中并注释。
