---
layout: post
title: "xl2tp client without ipsec"
category: linux
tags: [gentoo, xl2tp, client]
---

### 参考

**[有关xl2tp client的设置](https://wiki.archlinux.org/index.php/L2TP/IPsec_VPN_client_setup#xl2tpd)**


#### /etc/ppp/options.l2tpd.client



```
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-mschap-v2  # 其中windows客户端使用了 mschap-v2
noccp
noauth
idle 1800
mtu 1410
mru 1410
defaultroute
usepeerdns
debug
lock
connect-delay 5000
name your_vpn_username # 注意和之前的配置不同，不再另外配置chap-secrets
password your_password
```
