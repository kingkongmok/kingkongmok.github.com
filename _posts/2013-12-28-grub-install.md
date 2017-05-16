---
layout: post
title: "grub install"
category: linux
tags: [linux, boot, grub2]
---

**[ arch比较详细的文档 ]( https://wiki.archlinux.org/index.php/GRUB )**
##先删除
记得先删除 /boot/grub

##命令

```
sudo grub2-install --target=i386-pc --recheck --debug --boot-directory=/mnt/sda1 /dev/sda
```

---

## [efi stub kernel](https://wiki.gentoo.org/wiki/EFI_stub_kernel#Configuration)

+. CONFIG_CMDLINE
+. CONFIG_INITRAMFS_SOURCE
+. **CONFIG_CMDLINE** 这个需要设置grub的linux参数，例如**root=/dev/sda1 ro single
init=/usr/lib/systemd/systemd*

将kernel拷贝到EFI，启动


```
cp -avf /boot/vmlinux /boot/efi/boot/bootx64.efi
```


---

## grub2 on efi/GPT

+. 将grub响应模块安装到/boot

```
grub-install --efi-directory=/boot
```

+. 将grub的efi拷贝到EPI

```
cp -avf /boot/efi/gentoo/grubx64.efi /boot/efi/boot/bootx64.efi
```
