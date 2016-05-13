---
layout: post
title: "column example"
category: linux
tags: [command, column]
---

有人建议使用column来排列输出，效果不错：

<pre lang="bash" line="1">
kk@debian:~$ cat testinput.txt 
udp 2654  58 packets
udp 7273  2 packets

udp 7276  1 packets


udp 7276  1 packets
udp 7276  1 packets
udp 7276  1 packets
udp 7276  1 packets
tcp 7278  1 packets




udp 7280  1 packets
udp 7275  1 packets
udp 7281  1 packets

udp 7281  0 packets
udp 7281  2 packets
ckets
udp 7274  1 packets
udp 7282  1 packets
udp 5656  1 packets
udp 7277  1 packets
udp 7276  1 packets
udp 7273  2 packets
kk@debian:~$ cat testinput.txt  | column -t
udp  2654  58  packets
udp  7273  2   packets
udp  7276  1   packets
udp  7276  1   packets
udp  7276  1   packets
udp  7276  1   packets
udp  7276  1   packets
tcp  7278  1   packets
udp  7280  1   packets
udp  7275  1   packets
udp  7281  1   packets
udp  7281  0   packets
udp  7281  2   packets
tcp  7279  1   packets
udp  7274  1   packets
udp  7282  1   packets
udp  5656  1   packets
udp  7277  1   packets
udp  7276  1   packets
udp  7273  2   packets
</pre>


