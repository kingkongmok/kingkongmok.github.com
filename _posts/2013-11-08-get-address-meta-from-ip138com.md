---
layout: post
title: "get address meta from ip138.com"
category: web 
tags: [ 138.com, 地址 ip ]
---
{% include JB/setup %}

小伙伴们需要通过ip获取物理地址，利用了下ip138.com的接口

```perl
perl -e 'for(qx#curl -s "http://www.ip138.com/ips138.asp?ip=@ARGV&action=2" | iconv -f gbk -t utf8#){print "@ARGV\t$1\n" if /数据：(.*?)\</}  ' www.baidu.com
```
