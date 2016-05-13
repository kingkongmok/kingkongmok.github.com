---
layout: post
title: "trinary operator get maximum"
category: perl
tags: [trinary operator, maximum, perl]
---

<pre lang="perl">
perl -ne '$a=$a>$_?$a:$_}{print $a' numb.txt
</pre>

<pre lang="bash">
kk@debian:~$ cat test2.txt 
b       0
c       1
d       2
e       3
f       4
g       5
h       6
i       7
j       8
k       9
b       3
c       4
d       5
e       6
f       7
g       8
h       9
i       10
j       11
k       12
b       2
c       3
d       4
e       5
f       6
g       7
h       8
i       9
j       10
k       11

kk@debian:~$ cat test2.txt | perl -ne '($a,$b)=split;$h{$a}=$h{$a}>$b?$h{$a}:$b }{print"$k\t$v\n"while($k,$v)=each%h'
e       6
d       5
j       11
c       4
k       12
h       9
b       3
g       8
f       7
i       10

</pre>

