---
layout: post
title: "vimium插件的快捷键设置"
category: chrome
tags: []
---
{% include JB/setup %}

```
# 原来的f和F分别是"Open a link in the current tab"和"Open URL, bookmark, or history entry", 现在取消
unmap f
unmap F
# 使用熟悉的b和f作为上下键
map b scrollPageUp
map f scrollPageDown
# 使用e和E导航
map E LinkHints.activateModeWithQueue
map e LinkHints.activateMode
# disable "Open the clipboard's URL in the current tab"
unmap p
```
