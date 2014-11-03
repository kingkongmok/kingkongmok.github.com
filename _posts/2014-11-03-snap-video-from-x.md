---
layout: post
title: "snap video from X"
category: linux
tags: [X, video, record, ffmpeg]
---
{% include JB/setup %}

来自[最牛bash](http://www.isspy.com/most_useful_linux_commands_1/)的介绍。

```bash
ffmpeg -f x11grab -s wxga -r 25 -i :0.0 -sameq /tmp/out.mpg

    -f x11grab 指定输入类型。因为x11的缓冲区不是普通的视频文件可以侦测格式，必须指定后ffmpeg才知道如何获得输入。
    -s wxga 设置抓取区域的大小。wxga是1366*768的标准说法，也可以换成-s 800×600的写法。
    -r 25 设置帧率，即每秒抓取的画面数。
    -i :0.0 设置输入源，本地X默认在0.0
    -sameq 保持跟输入流一样的图像质量，以用来后期处理。
```

