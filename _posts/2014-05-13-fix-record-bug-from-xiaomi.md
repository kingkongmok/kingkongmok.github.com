---
layout: post
title: "fix record bug from xiaomi 小米2S的3秒录音bug修复"
category: android
tags: [record]
---

小米2s使用cm系统有3秒录音bug，按照[论坛](http://www.miui.com/thread-1466054-1-1.html)的做法是要下载锤子的[rom](http://pan.baidu.com/share/link?shareid=972519004&uk=3559839934)然后更换以下文件：

```
/system/lib/hw/audio.primary.msm8960.so
/system/lib/hw/audio_policy.msm8960.so
```

我已经将文件保存于~/.android/

