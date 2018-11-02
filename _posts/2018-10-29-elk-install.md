---
layout: post
title: "elk install"
category: elk
tags: [elk]
---

###  [create a graph](https://stackoverflow.com/questions/22053926/how-do-i-create-a-stacked-graph-of-http-codes-in-kibana/26471825#26471825)

---

### [running-filebeat-in-windows](https://stackoverflow.com/questions/41751605/running-filebeat-in-windows)

+ Move the extracted directory into Program Files.

```
PS > mv filebeat-5.1.2-windows-x86_64 "C:\Program Files\Filebeat"
```

+ install the filebeat service.

```
PS > cd "C:\Program Files\Filebeat"
PS C:\Program Files\Filebeat> powershell.exe -ExecutionPolicy UnRestricted -File .\install-service-filebeat.ps1
```

+ Edit the filebeat.yml config file and test your config.

```
PS C:\Program Files\Filebeat> .\filebeat.exe -e -configtest
```

+ (Optional) Run Filebeat in the foreground to make sure everything is working correctly. 

```
PS C:\Program Files\Filebeat> .\filebeat.exe -c filebeat.yml -e -d "*"
```

+ Start the service.

```
PS > Start-Service filebeat
```


