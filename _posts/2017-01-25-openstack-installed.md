---
title: "openstack install"
layout: post
category: linux
---

## [newton](http://docs.openstack.org/project-install-guide/newton/)安装

---

### [vnc无法显示](https://ask.openstack.org/en/question/34649/unable-to-resolve-the-servers-dns-address/)

* Q: dashboard中出现的vnc http链接不正确，显示为 **http://controller:6080/vnc_auto.html**

* A: 修改compute结点的 /etc/nova/nova.conf, 添加

    ```
    novncproxy_base_url=http://188.15.223.81:6080/vnc_auto.html
    ```

---

### [swift Error](https://ask.openstack.org/en/question/93267/unable-to-start-swift-proxy-liberasurecode-missing-libshssso/)

> 在object1和object2结点，安装swift并启动后，用**systemctl status**查看，发现异常

    ```
    liberasurecode_instance_create: dynamic linking error libshss.so.1: cannot open shared object file: No such file or directory
    ```

* launchpad认为不是bug](https://bugs.launchpad.net/kolla/+bug/1552669)
