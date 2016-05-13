---
layout: post
title: "grub reinstall"
category: linux
tags: [linux, boot, grub2]
---

**[ arch比较详细的文档 ]( https://wiki.archlinux.org/index.php/GRUB )**
##先删除
记得先删除 /boot/grub

##命令

{% highlight bash %}
sudo grub2-install --target=i386-pc --recheck --debug --boot-directory=/mnt/sda1 /dev/sda
{% endhighlight %}
