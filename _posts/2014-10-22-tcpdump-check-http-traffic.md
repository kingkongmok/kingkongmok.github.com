---
layout: post
title: "tcpdump"
category: linux
tags: [tcpdump, http]
---


使用tcpdump可以用-w的参数将包记录下来，当然也可以直接-A来现场查看简单分析

## 参数和重要信息解析：

***-A*** 使用ascii打印，基本是为http服务的

***-n*** 不解析DNS

***-s*** 设置取每数据包的字节大小，其实这个一般默认65535就ok了，不必另外设置

***-l*** Make stdout line buffered. 用于grep或者tee使用


```
Flags are some combination of S (SYN), F (FIN), P (PUSH),  R  (RST),  U
       (URG),  W  (ECN  CWR), E (ECN-Echo) or `.' (ACK), or `none' if no flags
       are set.  Data-seqno describes the portion of sequence space covered by
       the data in this packet (see example below).  Ack is sequence number of
       the next data expected the other direction on this connection.   Window
       is  the  number  of  bytes  of receive buffer space available the other
       direction on this connection.  Urg indicates there is `urgent' data  in
       the  packet.  Options are tcp options enclosed in angle brackets (e.g.,
       <mss 1024>).
```

所以，如果具体分析的时候，可以针对***[P\.?]***来考虑，当然必须包括***-l***参数。


### PTR

一个ssh的登录时候反向DNS查找10网段PTR的过程

```
kk@ins14 ~ $ sudo tcpdump -i enp0s3 -A -n -s 0 not port 22 -l  
error : ret -1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on enp0s3, link-type EN10MB (Ethernet), capture size 65535 bytes
15:10:52.775779 IP 10.0.2.15.42343 > 1.2.4.8.53: 15126+ PTR? 2.2.0.10.in-addr.arpa. (39)
E..C..@.@...
........g.5./.Y;............2.2.0.10.in-addr.arpa.....
15:10:57.781058 IP 10.0.2.15.42343 > 1.2.4.8.53: 15126+ PTR? 2.2.0.10.in-addr.arpa. (39)
E..C..@.@...
........g.5./.Y;............2.2.0.10.in-addr.arpa.....
15:10:57.824162 IP 1.2.4.8.53 > 10.0.2.15.42343: 15126 NXDomain* 0/1/0 (98)
E..~....@.d.....
....5.g.j._;............2.2.0.10.in-addr.arpa.............*0./  localhost..nobody.invalid.............. :...*0
15:11:58.395804 ARP, Request who-has 10.0.2.2 tell 10.0.2.15, length 28
..........'.y.
.........
...
```

### http 过程
一个使用iptables nat 8080 -> 80 的访问过程

```
kk@ins14 ~ $ sudo tcpdump -i enp0s3 -A -n -s 0 not port 22 -l  
error : ret -1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on enp0s3, link-type EN10MB (Ethernet), capture size 65535 bytes
15:20:17.843460 IP 10.0.2.2.54993 > 10.0.2.15.80: Flags [S], seq 123904001, win 65535, options [mss 1460], length 0
-..@.U.
...
......P.b......`.............
15:20:17.843541 IP 10.0.2.15.80 > 10.0.2.2.54993: Flags [S.], seq 4134928462, ack 123904002, win 29200, options [mss 1460], length 0
E..,..@.@.".
...
....P...v.N.b..`.r../......
15:20:17.844194 IP 10.0.2.2.54993 > 10.0.2.15.80: Flags [.], ack 1, win 65535, length 0
...@.U.
...
......P.b...v.OP..."x........
15:20:17.844234 IP 10.0.2.2.54993 > 10.0.2.15.80: Flags [P.], seq 1:375, ack 1, win 65535, length 374
/..@.T.
...
......P.b...v.OP.......GET / HTTP/1.1
Host: localhost
Connection: keep-alive
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
User-Agent: Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.27 Safari/537.36
Accept-Encoding: gzip, deflate, sdch
Accept-Language: en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2


15:20:17.844253 IP 10.0.2.15.80 > 10.0.2.2.54993: Flags [.], ack 375, win 30016, length 0
E..()W@.@..h
...
....P...v.O.b.xP.u@.+..
15:20:17.847424 IP 10.0.2.15.80 > 10.0.2.2.54993: Flags [P.], seq 1:1408, ack 375, win 30016, length 1407
E...)X@.@...
...
....P...v.O.b.xP.u@....HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
Accept-Ranges: bytes
ETag: W/"1179-1409540293000"
Last-Modified: Mon, 01 Sep 2014 02:58:13 GMT
Content-Type: text/html
Content-Length: 1179
Date: Wed, 22 Oct 2014 07:20:17 GMT

<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD><TITLE>Apache Tomcat Examples</TITLE>
<META http-equiv=Content-Type content="text/html">
</HEAD>
<BODY>
<P>
<H3>Apache Tomcat Examples</H3>
<P></P>
<ul>
<li><a href="servlets">Servlets examples</a></li>
<li><a href="jsp">JSP Examples</a></li>
<li><a href="websocket">WebSocket Examples</a></li>
</ul>
</BODY></HTML>

15:20:17.848181 IP 10.0.2.2.54993 > 10.0.2.15.80: Flags [.], ack 1408, win 65535, length 0
0..@.U.
...
......P.b.x.v..P.............
15:20:18.095089 IP 10.0.2.2.54994 > 10.0.2.15.80: Flags [S], seq 123968001, win 65535, options [mss 1460], length 0
1..@.U.
...
......P.c......`.............
15:20:18.095168 IP 10.0.2.15.80 > 10.0.2.2.54994: Flags [S.], seq 4014723904, ack 123968002, win 29200, options [mss 1460], length 0
E..,..@.@.".
...
....P...K.@.c..`.r../......
15:20:18.095501 IP 10.0.2.2.54994 > 10.0.2.15.80: Flags [.], ack 1, win 65535, length 0
2..@.U.
...
......P.c...K.AP...\.........
^C
10 packets captured
11 packets received by filter
0 packets dropped by kernel
```
