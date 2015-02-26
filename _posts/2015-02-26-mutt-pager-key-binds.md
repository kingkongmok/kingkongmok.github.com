---
layout: post
title: "mutt的翻页按键设置"
category: linux
tags: [mutt, key, bindings]
---
{% include JB/setup %}

### [来源](http://stevelosh.com/blog/2012/10/the-homely-mutt/#reading-email)

这里的mutt设置可以让mutt在读邮件的时候使用vim的快捷键。因为重置了列***f  forward***的功能，需要forward的时候退出到列表再进行即可。

### page key bindings

```
# Pager Key Bindings ---------------------------------
bind pager k  previous-line
bind pager b  previous-page
bind pager j  next-line
bind pager f  next-page
bind pager gg top
bind pager G  bottom

bind pager R  group-reply

# View attachments properly.
bind attach <return> view-mailcap
```
