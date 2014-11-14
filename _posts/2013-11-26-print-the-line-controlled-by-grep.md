---
layout: post
title: "print the line controlled by grep Grep命令"
category: perl
tags: [line, grep, number]
---
{% include JB/setup %}

<pre lang="bash">
#print only lines 13,19
perl -ne 'print if grep/s./,(13,19)' file
</pre>


<pre lang="bash">
#print from line 13 to line 19
perl -ne 'print if grep/s./,(13..19)' file
</pre>

<pre lang="perl">
print $_ unless grep {$.==$_} @array
</pre>
