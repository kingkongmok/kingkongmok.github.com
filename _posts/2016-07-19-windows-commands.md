---
title: "windows commands"
layout: post
category: windows
---


### IIS 管理器


```
InetMgr
```

---


## [add user](https://www.windows-commandline.com/add-user-from-command-line/)

```
NET USER kenneth <password> /ADD
```

## delete user


```
net user kenneth /delete
```

## change password

```
NET USER kenneth <password>
```

---

## windows version

```
winver
```

---


## 计划任务 scheduled tasks

```
taskschd.msc
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
NET SHARE LogFiles="C:\inetpub\logs\LogFiles" /GRANT:kenneth,FULL
```

### firewall

默认会禁止tcp445，需要将此rule disable才能共享

---

### 搜索共享

```
C:\Users\User>net share

共享名       资源                            注解

-------------------------------------------------------------------------------
C$           C:\                             默认共享
IPC$                                         远程 IPC
print$       C:\WINDOWS\system32\spool\drivers
                                             打印机驱动程序
ADMIN$       C:\WINDOWS                      远程管理
Users        C:\Users
命令成功完成。
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

### route add

```
#route ADD destination_network MASK subnet_mask  gateway_ip metric_cost
route add 77.77.77.36 mask 255.255.255.255 172.26.31.254

# route add 77.77.77.36 mask 255.255.255.255 172.26.31.254 -p
```

---

### 任务管理器

```
%windir%\system32\taskschd.msc /s
```

---

### telnet client install

在命令行在安装，安装后退出cmd，重新进入cmd后就有telnet命令

```
pkgmgr /iu:"TelnetClient"

or

dism /online /Enable-Feature /FeatureName:TelnetClient
```

---

### check tcp status


netstat -nb  | find  /i "time_wait" /c
