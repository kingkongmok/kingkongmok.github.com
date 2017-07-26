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

## [All Data is InnoDB](https://dba.stackexchange.com/questions/19532/safest-way-to-perform-mysqldump-on-a-live-system-with-active-reads-and-writes)

```
mysqldump -uuser -ppass --single-transaction --routines --triggers
--master-data=2 --all-databases > backup_db.sql
```

* **--single-transaction** produces a checkpoint that allows the dump to capture all data prior to the checkpoint while receiving incoming changes. Those incoming changes do not become part of the dump. That ensures the same point-in-time for all tables.

* **--routines** dumps all stored procedures and stored functions

* **--triggers** dumps all triggers for each table that has them

* **--master-data=2** the CHANGE MASTER TO statement is written as an SQL comment, and thus is informative only; it has no effect when the dump file is reloaded. 

    The **--master-data** option automatically turns off --lock-tables. It also turns on **--lock-all-tables**

---

## MyISAM 

* --lock-tables

---

## [不重启的情况下备份](http://lizhenliang.blog.51cto.com/7876557/1669829)

```
# mysqldump -uroot -p123 --routines --single_transaction --master-data=2
--databases weibo > weibo.sql
```

* **--routines**：导出存储过程和函数
* **--single_transaction**：导出开始时设置事务隔离状态，并使用一致性快照开始事务，然后unlock tables;而lock-tables是锁住一张表不能写操作，直到dump完毕。
* **--master-data**：默认等于1，将dump起始（change master to）binlog点和pos值写到结果中，等于2是将change master to写到结果中并注释。

在备份文件weibo.sql查看binlog和pos值

```
# head -25 weibo.sql
-- CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=107;
#大概22行
```

