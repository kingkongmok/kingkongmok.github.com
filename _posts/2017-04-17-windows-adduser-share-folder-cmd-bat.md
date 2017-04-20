---
title: "windows adduser and share command line"
layout: post
category: windows
---

## [add user](https://www.windows-commandline.com/add-user-from-command-line/)

```
NET USER kenneth <password> /ADD
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
