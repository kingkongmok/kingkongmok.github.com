---
layout: post
title: "perl1line escape doller signs using ENV"
category: perl
tags: [perl, perl1line, escape, signs, env]
---
{% include JB/setup %}

**https://blogs.oracle.com/ksplice/entry/the_top_10_tricks_of**
{% highlight bash %}
kk@R61e:~$ env re="['\"]" perl -lne '@F=split/$ENV{re}/,$_; printf "%02d %s\n", $a++ , @F[1] if /^menu/' /boot/grub/grub.cfg 
00 Ubuntu, with Linux 3.2.0-53-generic
01 Ubuntu, with Linux 3.2.0-53-generic (recovery mode)
02 Ubuntu, with Linux 3.2.0-52-generic
03 Ubuntu, with Linux 3.2.0-52-generic (recovery mode)
04 Memory test (memtest86+)
05 Memory test (memtest86+, serial console 115200)
06 Microsoft Windows XP Professional (on /dev/sda1)
{% endhighlight %}


{% highlight bash %}
#原来原始数据中，会出现“和'，这个在1line实现是比较麻烦的。不可以使用-F'[foobar]'
kk@R61e:~$ perl -ne 'printf "%02d %s", $a++, $_ if /^menu/ ' /boot/grub/grub.cfg 
00 menuentry 'Ubuntu, with Linux 3.2.0-53-generic' --class ubuntu --class gnu-linux --class gnu --class os {
01 menuentry 'Ubuntu, with Linux 3.2.0-53-generic (recovery mode)' --class ubuntu --class gnu-linux --class gnu --class os {
02 menuentry 'Ubuntu, with Linux 3.2.0-52-generic' --class ubuntu --class gnu-linux --class gnu --class os {
03 menuentry 'Ubuntu, with Linux 3.2.0-52-generic (recovery mode)' --class ubuntu --class gnu-linux --class gnu --class os {
04 menuentry "Memory test (memtest86+)" {
05 menuentry "Memory test (memtest86+, serial console 115200)" {
06 menuentry "Microsoft Windows XP Professional (on /dev/sda1)" --class windows --class os {
{% endhighlight %}