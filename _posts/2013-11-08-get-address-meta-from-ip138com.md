---
layout: post
title: "get address meta from ip138.com 通过ip138查地址的脚本"
category: web 
tags: [ 138.com, curl, 地址]
---

小伙伴们需要通过ip获取物理地址，利用了下ip138.com的接口

### using bash
```
perl -e 'for(qx#curl -s "http://www.ip138.com/ips138.asp?ip=@ARGV&action=2" | iconv -f gbk -t utf8#){print "@ARGV\t$1\n" if /数据：(.*?)\</}' www.baidu.com
```

### using perl

```perl
use Encode      qw( decode encode );
use LWP::Simple qw( get );

my $URL     = "http://www.ip138.com/ips138.asp?ip=@ARGV&action=2";
my $web_enc = 'gbk';
my $out_enc = 'utf8';

my $web_octets = get($URL);
my $chars      = decode($web_enc, $web_octets);
my $out_octets = encode($out_enc, $chars);
(my $result) =  $out_octets =~ /数据：(.*?)\</;
print $result;
```
