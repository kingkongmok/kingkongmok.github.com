---
layout: post
title: "linux boot from usb"
category: linux
tags: [linux, boot, usb, initramfs, modules]
---
{% include JB/setup %}

**https://help.ubuntu.com/community/BootFromUSB**

拷贝并修改/etc/fstab和grub.cfg

以下说说如何修改`initramfs`：

##initramfs

{% highlight bash %}
#修改initrd所需加载的usb驱动，一般内核不加载usb2.0驱动的。
sudo cp /etc/initramfs-tools/modules{,.orig}
cat <<EOF |sudo tee -a /etc/initramfs-tools/modules
usbcore
sd_mod
ehci_hcd
uhci_hcd
ohci_hcd
usb_storage
scsi_mod
EOF
{% endhighlight %}

##这个是用于内核增加加载时间的。

<pre lang="bash">
sudo perl -i.orig -lpe'print"WAIT=15"if$.==1' /etc/initramfs-tools/initramfs.conf
</pre>


**生成新的initrd，当然更新内核也会自动相应更新，因为内核的更新也重新mkinitramfs的。**

<pre lang="bash">
sudo mkinitramfs -o iso/boot/initrd.gz `kernelversion`
</pre>

完成内核方面的优化后，就是修改/etc/fstab和/boot/grub/grub.cfg的更新了。
/etc/fstab没有好的方法，只能手工修改，当然可以借助uuid的方式来判断分区，通过file -s /etc/block来
查询。
grub可以借助update-grub2来更新，但是需要了解hd0和hd1可能会调换，需要perl的s/foo/bar/来修正。
安装grub2的方法一般都是使用grub-install，但一般都是需要挂载dev, sys proc并chroot后来做。
