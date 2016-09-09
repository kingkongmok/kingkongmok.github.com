---
title: "using Zabbix Agent 3.0 XXL with Docker"
layout: post
category: docker
---

### [zabbix xxl](https://hub.docker.com/r/monitoringartist/zabbix-3.0-xxl/)

#### Standard Dockerized Zabbix deployment

```
# create /var/lib/mysql as persistent volume storage
docker run -d -v /var/lib/mysql --name zabbix-db-storage busybox:latest

# start DB for Zabbix - default 1GB innodb_buffer_pool_size is used
docker run \
    -d \
    --name zabbix-db \
    -v /backups:/backups \
    -v /etc/localtime:/etc/localtime:ro \
    --volumes-from zabbix-db-storage \
    --env="MARIADB_USER=zabbix" \
    --env="MARIADB_PASS=my_password" \
    monitoringartist/zabbix-db-mariadb

# start Zabbix linked to started DB
docker run \
    -d \
    --name zabbix \
    -p 80:80 \
    -p 10051:10051 \
    -v /etc/localtime:/etc/localtime:ro \
    --link zabbix-db:zabbix.db \
    --env="ZS_DBHost=zabbix.db" \
    --env="ZS_DBUser=zabbix" \
    --env="ZS_DBPassword=my_password" \
    monitoringartist/zabbix-3.0-xxl:latest
# wait ~60 seconds for Zabbix initialization
# Zabbix web will be available on the port 80, Zabbix server on the port 10051
```

#### Examples of admin tasks

```
# Backup of DB Zabbix - configuration data only, no item history/trends
docker exec \
    -ti zabbix-db \
    /zabbix-backup/zabbix-mariadb-dump -u zabbix -p my_password -o /backups

# Full backup of Zabbix DB
docker exec \
    -ti zabbix-db \
    bash -c "\
    mysqldump -u zabbix -pmy_password zabbix | \
    bzip2 -cq9 > /backups/zabbix_db_dump_$(date +%Y-%m-%d-%H.%M.%S).sql.bz2"

# Restore Zabbix DB
# remove zabbix server container
docker rm -f zabbix
# restore data from dump (all current data will be dropped!!!)
docker exec -i zabbix-db sh -c 'bunzip2 -dc /backups/zabbix_db_dump_2016-05-25-02.57.46.sql.bz2 | mysql -uzabbix -p --password=my_password zabbix'
# run zabbix server again
docker run ...
```

---

### 自定义mysql路径

```
docker run -d -v /var/lib/mysql:/var/lib/mysql --name zabbix-db-storage busybox:mysql
```

### 实际测试运行的脚本

```
docker run -d -v /var/lib/mysql --name zabbix-db-storage busybox:latest
docker run -d --name zabbix-db -v /backups:/backups -v /etc/localtime:/etc/localtime:ro --volumes-from zabbix-db-storage --env="MARIADB_USER=zabbix" --env="MARIADB_PASS=my_password" monitoringartist/zabbix-db-mariadb
docker run -d --name zabbix -p 80:80 -p 10051:10051 -v /etc/localtime:/etc/localtime:ro --link zabbix-db:zabbix.db --env="ZS_DBHost=zabbix.db" --env="ZS_DBUser=zabbix" --env="ZS_DBPassword=my_password" monitoringartist/zabbix-3.0-xxl:latest
```
