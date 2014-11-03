---
layout: post
title: "reset gnome fonts setting"
category: linux
tags: [gnome, font]
---
{% include JB/setup %}

整理的时候发现的，当然现在是直接修改***~/.config/fontconfig/***和***~/.gtkrc-2.0***了，但gnome的配置还是记录一下：

```
gconftool-2 --unset /desktop/gnome/interface/font_name
gconftool-2 --unset /desktop/gnome/interface/document_font_name
gconftool-2 --unset /desktop/gnome/interface/monospace_font_name
gconftool-2 --unset /apps/metacity/general/titlebar_font
gconftool-2 --unset /apps/nautilus/preferences/desktop_font
```
