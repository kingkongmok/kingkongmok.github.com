---
layout: post
title: "nessus on docker update plugins"
category: linux
tags: [nessus, docker]
---

### docker安装

+ docker.io/mikenowak/nessus

```
    nessus:
        image: docker.io/mikenowak/nessus
        container_name: nessus
        restart: always
        volumes:
            - /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime
            - /root/container/nessus/:/opt/nessus/
        ports:
            - 8834:8834

```

---

### [更新](https://docs.tenable.com/nessus/commandlinereference/Content/RegisterAScannerOnline.htm)

```
/opt/nessus/sbin/nessuscli fetch --register xxxx-xxxx-xxxx-xxxx
```

```
Your Activation Code has been registered properly - thank you.

----- Fetching the newest updates from nessus.org -----

Nessus Plugins: Downloading (2%)    
...
Nessus Plugins: Downloading (99%)   
Nessus Plugins: Unpacking (0%)  
...
Nessus Plugins: Unpacking (92%) 
Nessus Plugins: Complete    

Nessus Core Components: Downloading (3%)    
...
Nessus Core Components: Complete    

* Nessus Plugins are now up-to-date and the changes will be automatically processed by Nessus.
* Nessus Core Components was NOT updated.  This update requires special processing that must be performed when Nessus is shut down.  Please shut down the Nessus service and retry the update
```
