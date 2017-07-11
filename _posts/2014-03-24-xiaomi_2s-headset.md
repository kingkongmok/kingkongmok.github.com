---
layout: post
title: "xiaomi_2s headset"
category: android
tags: [headset]
---

## key test ##

使用[keytest](https://github.com/chrisboyle/keytest/downloads)apk，来检测一下到底是线控是什么key，[原文在此](http://forum.xda-developers.com/nexus-4/general/guide-headset-controls-t1997277)

## 修改配置文件 ##
小米2s的cyanogenmod 10.1的配置文件找不到，只能修改`/system/usr/keylayout/Generic.kl`文件了


```
#key 257   BUTTON_2
key 257   MEDIA_PLAY_PAUSE        WAKE
#key 260   BUTTON_5
key 260   MEDIA_NEXT    WAKE
```

## 旧手机HTC G7 ##

旧的G7使用[SYLLABLE 赛尔贝尔 G02A 入耳式立体声面条耳机耳麦](http://www.amazon.cn/gp/product/B00EP5EA9I/ref=oh_details_o00_s00_i00?ie=UTF8&psc=1)时，可以检测到三个按钮，分别是上165,中226,下163。看来小米2s的cyanogenmod是有问题啦。
