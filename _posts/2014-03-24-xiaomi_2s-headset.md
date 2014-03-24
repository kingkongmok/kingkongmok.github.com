---
layout: post
title: "xiaomi_2s headset"
category: android
tags: [headset]
---
{% include JB/setup %}

## key test ##

使用[keytest](https://github.com/chrisboyle/keytest/downloads)apk，来检测一下到底是线控是什么key，[原文在此](http://forum.xda-developers.com/nexus-4/general/guide-headset-controls-t1997277)

## 修改配置文件 ##
小米2s的cyanogenmod 10.1的配置文件找不到，只能修改`/system/usr/keylayout/Generic.kl`文件了


{% highlight bash %}
#key 257   BUTTON_2
key 257   MEDIA_PLAY_PAUSE        WAKE
#key 260   BUTTON_5
key 260   MEDIA_NEXT    WAKE
{% endhighlight %}
