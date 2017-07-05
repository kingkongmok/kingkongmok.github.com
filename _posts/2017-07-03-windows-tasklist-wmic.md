---
title: "windows tasklist wmic commands"
layout: post
category: windows
---

### [Show EXE file path of running processes on the command-line in Windows](https://superuser.com/questions/768984/show-exe-file-path-of-running-processes-on-the-command-line-in-windows)

```
tasklist | find "mysql"
```

```
wmic process where "name='mysqld.exe'" get ProcessID, ExecutablePath
```

---
