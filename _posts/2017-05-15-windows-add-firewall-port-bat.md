---
title: "Batch file add firewall port"
layout: post
category: windows
---

### [add port](http://stackoverflow.com/questions/15171255/how-to-open-ports-on-windows-firewall-through-batch-file)

```
ECHO OFF
set PORT=10050
set RULE_NAME="zabbix_agentd"

netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)
pause
```
---

### windows 2008+ add zabbix port

```
netsh advfirewall firewall add rule name=zabbix_agentd dir=in action=allow
protocol=TCP localport=10050
```
