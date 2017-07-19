---
title: "windows commands"
layout: post
category: windows
---

## [add user](https://www.windows-commandline.com/add-user-from-command-line/)

```
NET USER kenneth <password> /ADD
```

## change password

```
NET USER kenneth <password>
```


---

## IIS log share

### 2003

```
icacls "C:\Windows\System32\LogFiles" /grant kenneth:(OI)(CI)F /T
NET SHARE LogFiles="C:\Windows\System32\LogFiles" /GRANT:kenneth,READ
```

### 2008

```
icacls "C:\inetpub\logs\LogFiles" /grant kenneth:(OI)(CI)F /T
NET SHARE LogFiles="C:\inetpub\logs\LogFiles" /GRANT:kenneth,READ
```
---

## [firewall add port](http://stackoverflow.com/questions/15171255/how-to-open-ports-on-windows-firewall-through-batch-file)

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

### change_rdp_port.reg

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal
Server\WinStations\RDP-Tcp]
"PortNumber"=dword:000054bd
```

---

##  "windows tasklist wmic commands"

### [Show EXE file path of running processes on the command-line in Windows](https://superuser.com/questions/768984/show-exe-file-path-of-running-processes-on-the-command-line-in-windows)

```
tasklist | find "mysql"
```

```
wmic process where "name='mysqld.exe'" get ProcessID, ExecutablePath
```

---
