---
layout: post
title: "kindlegen"
category: gentoo
tags: [kindle, calibre, mobi]
---
{% include JB/setup %}

[kindlegen](http://wiki.gentoo.org/wiki/Amazon_Kindle)是[amazon](http://www.amazon.com/gp/feature.html?docId=1000765211)提供的html转换mobi的软件。

### download

```
$ curl -LOJ http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz
```

### txt 转码

```
perl -i.bak -ne 's/\r// ; print if /./' filename.txt
iconv -f gbk -c  filename.txt > newfilename.txt
```

### [txt->html](http://vim.wikia.com/wiki/Pasting_code_with_syntax_coloring_in_emails)

 这里使用vim转一下txt到html，注意要修改title部分，这个是显示的名称
 
```
:TOhtml
```

### html-mobi

使用刚刚下载的kindlegen来转换

```
perl -MHTML::TextToHTML -e 'my $conv = new HTML::TextToHTML(); $conv->txt2html(infile=>["$filename.txt"], outfile=>"filename.html", title=>"$filename", eight_bit_clean=>1  );'
```

在在<head></head>标签中加入以下

```
<style type="text/css">
body{
font-family: arial, sans-serif;
}
</style>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
```
