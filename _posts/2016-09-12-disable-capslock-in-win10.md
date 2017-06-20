---
title: "disable CapsLock in win10"
layout: post
category: windows
---

### [windows disable
capslock](https://www.howtogeek.com/howto/windows-vista/disable-caps-lock-key-in-windows-vista/)

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]
"Scancode Map"=hex:00,00,00,00,00,00,00,00,02,00,00,00,00,00,3a,00,00,00,00,00
```

---

### [windows10 disable
synaptics](http://jingyan.baidu.com/article/d5a880ebb6640613f147ccc7.html)

+ 进入Windows10电脑设置，当然也可以按Windows键+X同样也可以进入。
+ 点击设备，这个设备主要是关于蓝牙，打印机，鼠标等设置的。
+ 点击鼠标和触摸板，在Windows10叫触摸板，以前习惯叫触控板。
+ 直接点击其他鼠标选项。
+ 点击装置设置值，这里可以看到成功驱动的触摸板，点击禁用。

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


