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
mysqldump -uuser -ppass --single-transaction --routines --triggers --master-data=2 --all-databases > backup_db.sql
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
# mysqldump -uroot -p123 --routines --single_transaction --master-data=2 --databases weibo > weibo.sql


mysqldump --single-transaction --routines --triggers --master-data=2 --databases database1 database2 database3 | gzip > mysql.backup.sql.gz
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


---

### [mysql 删除 主从信息](://blog.csdn.net/wulantian/article/details/8463394)


```
mysql>change master to master_host=' ';
```

---

### mysql shutdown

```
mysqladmin -u root -ppassowrd shutdown
mysqladmin shutdown
```

---

### [install](https://dev.mysql.com/downloads/repo/yum/)


```
grep 'temporary password' /var/log/mysqld.log
SET GLOBAL validate_password_policy=LOW;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```

--- 


### [ERROR 1231 (42000)  Variable sql_mode NO_AUTO_CREATE_USER](https://stackoverflow.com/questions/55503831/error-1231-42000-with-sql-mode-when-trying-to-import-a-sql-dump-in-mysql-workb)

```
perl -pi -e 's/,NO_AUTO_CREATE_USER//g' dump.sql
```

---


### [mysql kill process](https://stackoverflow.com/questions/1903838/how-do-i-kill-all-the-processes-in-mysql-show-processlist)

```
mysql> select concat('KILL ',id,';') from information_schema.processlist
where user='root' and time > 200 into outfile '/tmp/a.txt';

mysql> source /tmp/a.txt;
```

---


### [Repair the MySQL Replication](https://www.howtoforge.com/how-to-repair-mysql-replication)

```
Last_Error: Error 'Duplicate key name 'idx_FromHost'' on query. Default database: 'Syslog'. Query: 'create index idx_FromHost on SystemEvents ( FromHost )'
```

```
mysql> STOP SLAVE;
#
# simply skip the invalid SQL query
# This tells the slave to skip one query (which is the invalid one that caused the replication to stop). 
# If you'd like to skip two queries, you'd use SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 2; instead and so on.
#
mysql> SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1;

mysql> START SLAVE;
mysql> SHOW SLAVE STATUS \G
```


---

在slave上删除一条记录

```
stop slave;
set global sql_slave_skip_counter=1;
start slave;
```

---

### [memory](https://stackoverflow.com/questions/1178736/mysql-maximum-memory-usage)

as 2G memory in OS

```
innodb_buffer_pool_size = 384M
key_buffer = 256M
query_cache_size = 1M
query_cache_limit = 128M
thread_cache_size = 8
max_connections = 400
innodb_lock_wait_timeout = 100
```

---

安全需要，添加超时

```
my.cnf 

plugin-load-add=connection_control.so
connection-control=FORCE_PLUS_PERMANENT
connection-control-failed-login-attempts=FORCE_PLUS_PERMANENT
connection_control_failed_connections_threshold=30
connection_control_min_connection_delay=600000
interactive_timeout=1800
```

---

slave read only

```
my.cnf

read_only=1
super_read_only=1
```

---

### [count rows](https://stackoverflow.com/questions/286039/get-record-counts-for-all-tables-in-mysql-database)

```
SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'CTMS';
```

---

+ 删除180日日志

```
4 5     * * *   root    mysql -e "PURGE BINARY LOGS BEFORE DATE(NOW() - INTERVAL 180 DAY);"
```
