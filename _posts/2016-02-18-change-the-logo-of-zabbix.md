---
layout: post
title: "修改zabbix在顶端的logo"
category: zabbix
tags: [logo]
---
{% include JB/setup %}


***[引用】(https://www.zabbix.com/forum/showthread.php?t=22814)***

---

#### ICO

+ Copy archive ICO to directory "/zabbix/images/general".

+ Edit the file "page_header.php" and locate the line containing the file name zabbix.ico. Replace the filename zabbix.ico by the name of the file you saved above.

+ Refresh the page that you access the zabbix and see that the icon has been changed.

---

#### logo

+ Copy archive logo to directory "/zabbix/images/general".

+ Edit the file "div.css" located in the / zabbix / styles and find the line that contains the file name zabbix.png. Replace the filename zabbix.png by the name of the file you saved earlier.

+ Refresh the page that you access the zabbix and see that the icon and logo has been changed.
