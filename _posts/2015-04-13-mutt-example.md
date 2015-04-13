---
layout: post
title: "mutt的使用"
category: linux
tags: [mutt, key, bindings, png, attachment]
---
{% include JB/setup %}

### [Embeding an image](http://stackoverflow.com/questions/14381071/embeding-an-image-in-an-email-using-linux-commands)

在使用mutt-1.5.23，可以支持发图片，***实际是先将图片转为base64，然后邮件明文传输，在邮件客户端可以自动转为图片***

#### image -> base64

将图片转为mailcontent.txt

```
for i in *png ; do echo -en "<img src=\"data:image/png;base64," `base64 $i` "\"\>\n" ; done > /tmp/mailcontent.txt
```

#### mutt send images

发邮件

```
mutt -e "set content_type=text/html" -s "subj here" -a "attachHere" -- reception@domain.com <  /tmp/mailcontent.txt
```

### [键绑定 key-binds](http://stevelosh.com/blog/2012/10/the-homely-mutt/#reading-email)

这里的mutt设置可以让mutt在读邮件的时候使用vim的快捷键。因为重置了列***f  forward***的功能，需要forward的时候退出到列表再进行即可。

#### key bindings examples

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

