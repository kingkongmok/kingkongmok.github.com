---
layout: post
title: "crontab "
category: linux
tags: [crontab, seperate, every, minute]
---
{% include JB/setup %}

### 需求：
每个程序，每三分钟运行一次，并错开

### crontab -l

```
2-59/3 *    * * *   date >> /tmp/testcront_3_2
1-59/3 *    * * *   date >> /tmp/testcront_3_1
0-59/3 *    * * *   date >> /tmp/testcront_3_0
```

## result

```
kk@ins14 ~ $ cat /tmp/testcront_3_0 
Fri Oct 31 14:15:01 CST 2014
Fri Oct 31 14:18:01 CST 2014
Fri Oct 31 14:21:01 CST 2014
Fri Oct 31 14:24:02 CST 2014
Fri Oct 31 14:27:01 CST 2014
Fri Oct 31 14:30:01 CST 2014
Fri Oct 31 14:33:01 CST 2014
kk@ins14 ~ $ cat /tmp/testcront_3_1
Fri Oct 31 14:13:01 CST 2014
Fri Oct 31 14:16:01 CST 2014
Fri Oct 31 14:19:01 CST 2014
Fri Oct 31 14:22:01 CST 2014
Fri Oct 31 14:25:01 CST 2014
Fri Oct 31 14:28:01 CST 2014
Fri Oct 31 14:31:01 CST 2014
Fri Oct 31 14:34:01 CST 2014
kk@ins14 ~ $ cat /tmp/testcront_3_2
Fri Oct 31 14:14:01 CST 2014
Fri Oct 31 14:17:01 CST 2014
Fri Oct 31 14:20:01 CST 2014
Fri Oct 31 14:23:01 CST 2014
Fri Oct 31 14:26:01 CST 2014
Fri Oct 31 14:29:01 CST 2014
Fri Oct 31 14:32:01 CST 2014
Fri Oct 31 14:35:01 CST 2014
```
