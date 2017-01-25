---
title: "openstack install"
layout: post
category: linux
---

## [newton](http://docs.openstack.org/project-install-guide/newton/)安装

---

### [vnc无法显示](https://ask.openstack.org/en/question/34649/unable-to-resolve-the-servers-dns-address/)

> Q: dashboard中出现的vnc http链接不正确，显示为 **http://controller:6080/vnc_auto.html**
> A: 修改compute结点的 /etc/nova/nova.conf
>     novncproxy_base_url=http://188.15.223.81:6080/vnc_auto.html

