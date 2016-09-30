---
title: "disable CapsLock in win10"
layout: post
category: windows
---

### windows

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]
"Scancode Map"=hex:00,00,00,00,00,00,00,00,02,00,00,00,00,00,3a,00,00,00,00,00
```

---

### [linux](http://www.cyberciti.biz/faq/linux-deactivate-caps-lock/)


xmodmap command to turn off caps key

```
$ echo 'xmodmap -e "remove lock = Caps_Lock"' >> ~/.bash_profile
```

setxkbmap command to turn off caps locks key

```
setxkbmap -option ctrl:nocaps
```


