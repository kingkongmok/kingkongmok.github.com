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

### [show jvm flas](http://techtalk.sanjaydhanwani.com/2019/02/find-jvm-start-arguments-of-java.html)

```
tasklist  | find "tomcat"

cmd> c:\<path to your java dir>\jcmd <PID> VM.command_line
cmd> c:\<path to your java dir>\jcmd <PID> VM.flags
```

---

### route add

```
#route ADD destination_network MASK subnet_mask  gateway_ip metric_cost
route add 77.77.77.36 mask 255.255.255.255 192.168.31.254

```

---

### 任务管理器

```
%windir%\system32\taskschd.msc /s
```

---

### telnet client install


输入 windows feature

在命令行在安装，安装后退出cmd，重新进入cmd后就有telnet命令

```
pkgmgr /iu:"TelnetClient"

or

dism /online /Enable-Feature /FeatureName:TelnetClient
```

---

### check tcp status


netstat -nb  | find  /i "time_wait" /c
<<<<<<< HEAD
=======

---

###  net use and net use delete

```

net use

net use * /delete

但另外需要凭据管理器进行删除

```
<<<<<<< HEAD

---

### show Proxy Server address

```

netsh winhttp show proxy

```
=======
>>>>>>> c316837544b8748ce8673cc68c2739627c102432
>>>>>>> b84e20ae0ce9125fd529700cc195063a8a15d429


---

[重装系统后桌面图标有的变白的解决方法](https://www.zhihu.com/question/35669038)

```
ie4uinit.exe -ClearIconCache
taskkill /IM explorer.exe /F
del /A /Q "%localappdata%\IconCache.db"
del /A /F /Q "%localappdata%"\Microsoft\windows\Explorer\iconcache*
```

---

winmtr

```
Windows环境下可以使用WinMTR测试：
https://www.alibabacloud.com/help/en/elastic-compute-service/latest/mtr-tool-usage-instructions-and-result-analysis#c03f5e4381wpe

WinMTR下载地址：
https://sourceforge.net/projects/winmtr/files/WinMTR-v092.zip/download?spm=a2c9r.12641821.0.0.18a15e3bgZqv4N
```
