---
title: "repair oem"
layout: post
category: oracle
---

## [Unable to determine local host from URL
REPOSITORY_URL](http://www.orafaq.com/forum/t/146583/)

```
C:\Documents and Settings\Administrator.sriram>emctl  status dbconsole
Unable to determine local host from URL
REPOSITORY_URL=http://sriram.domainname:%EM_UPLOAD_PORT%/em/
upload/
```

### 解决方法

```
set ORACLE_HOME=<your_oracle_home_name>
set ORACLE_SID=<your_sid_name>
 
 emca -config dbcontrol db -repos recreate
```
