---
layout: post
title: "how do i find the window dimensions and position accurately 获取X窗口的位置和大小"
category: linux
tags: [X, location, demensions]
---

##如何获取位置信息

[根据原文](http://unix.stackexchange.com/questions/14159/how-do-i-find-the-window-dimensions-and-position-accurately)


**用以下方法可以得到当前activewindow的x window信息。**

```
xwininfo -id $(xdotool getactivewindow)
```

##bash

**已经保存为xwinposition.sh文件**

```
#!/bin/bash
# Get the coordinates of the active window's
#    top-left corner, and the window's size.
#    This excludes the window decoration.
  unset x y w h
  eval $(xwininfo -id $(xdotool getactivewindow) |
    sed -n -e "s/^ \+Absolute upper-left X: \+\([0-9]\+\).*/x=\1/p" \
           -e "s/^ \+Absolute upper-left Y: \+\([0-9]\+\).*/y=\1/p" \
           -e "s/^ \+Width: \+\([0-9]\+\).*/w=\1/p" \
           -e "s/^ \+Height: \+\([0-9]\+\).*/h=\1/p" )
  echo -n "$x $y $w $h"
#
```

##用于ffmpeg的录像

[原文](http://www.commandlinefu.com/commands/view/148/capture-video-of-a-linux-desktop)
