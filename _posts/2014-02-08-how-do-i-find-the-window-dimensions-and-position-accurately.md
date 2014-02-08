---
layout: post
title: "how do i find the window dimensions and position accurately"
category: linux
tags: [X, location, demensions]
---
{% include JB/setup %}

##如何获取位置信息

[根据原文](http://unix.stackexchange.com/questions/14159/how-do-i-find-the-window-dimensions-and-position-accurately)


**用以下方法可以得到当前activewindow的x window信息。**

{% highlight bash %}
xwininfo -id $(xdotool getactivewindow)
{% endhighlight %}

##bash

**已经保存为xwinposition.sh文件**

{% highlight bash %}
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
{% endhighlight %}

##用于ffmpeg的录像

[原文](http://www.commandlinefu.com/commands/view/148/capture-video-of-a-linux-desktop)

{% highlight bash %}
ffmpeg -s `xdpyinfo | grep 'dimensions:'|awk '{print $2}'` -f x11grab -r 25 -i :0.0 /tmp/outputFile.mpg
{% endhighlight %}
