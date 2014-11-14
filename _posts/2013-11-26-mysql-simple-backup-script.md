---
layout: post
title: "mysql backup "
category: linux
tags: [mysql, backup]
---
{% include JB/setup %}

##备份

<pre lang="bash">
# --add-drop-database用于--all-databases or --databases的操作。单数据库无效。
nice /usr/local/mysql/bin/mysqldump -ukk -p igbsurvey | gzip > igbsurvey.sql.gz
</pre>

##还原(注意是zcat不是gzip)

<pre lang="bash">
nice zcat igbsurvey.sql.gz | mysql -uroot -p igbsurvey
</pre>
