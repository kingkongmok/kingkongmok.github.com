---
layout: post
title: "kindlegen"
category: gentoo
tags: [kindle, calibre, mobi]
---
{% include JB/setup %}

### [kindlegen](http://wiki.gentoo.org/wiki/Amazon_Kindle)是[amazon](http://www.amazon.com/gp/feature.html?docId=1000765211)提供的html转换mobi的软件。

####  [download](http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz)


### [grutatxt](https://github.com/angelortega/grutatxt)

其中比较有用的选型是

```
    -t|--title=TITLE           Document title (if unset,
                               level 1 heading is used)

    --encoding=ENCODING        Character encoding (default: iso-8859-1)
```

### [linux convert txt to mobi](http://rogerx.freeshell.org/programming/kindle-convert_txttomobi.html)

```
First, edit the text file and indent all lists (per grutatxt man page).  With this trick, grutatxt to treats all indents as lists.  This, in turn, prevents grutatxt from omitting the newline (carriage return) at the end of each list item creating a paragraph instead.  We don't want a paragraph for lists.  We want lists, and this trick can be used to prevent any lines of text from getting their newline stripped.  Later, if you don't like the look of indentions or free space prefixing your lists within the final HTML, you can edit the HTML page and simple delete the white space within the lists (between the <pre> tags).

To convert the text file into a new HTML file:
$ grutatxt < MyFile.txt > MyFile.html


To add a Title, edit the resulting HTML file with a text editor and enter a Title within the <Title></Title> HTML tags.  ie:
<Title>A Stone for Danny Fisher</Title>.

To add an Author, add the following entry directly below the first and only <META> HTML tag entry found at the top of the HTML file:

<meta name="Author" content="Harold Robbins">

Use kindlegen to convert the .html to a .mobi file:
$ kindlegen MyFile.html

Copy the file to your Kindle device:
$ copy MyFile.mobi to /media/Kindle/documents/recipes/

```

### 其他可能用到的脚本

#### 转换字符编码

```
enca -x utf8 -L zh < $1 > $TMPFILE
iconv -f gbk -c  filename.txt > newfilename.txt
```

#### 去空行，并自动空行，以便分段

```
perl -i -ne 'if(/\S/){s/\r//;print "$_\n"}' $TMPFILE
```


#### 中文空格开头的段落添加***<p>***以换行

```
perl -i -pe 's/^(?=　)/\<p\>/'  filename.html
```

#### [自动脚本](https://github.com/kingkongmok/kingkongmok.github.com/blob/master/bin/txt2mobi.sh)

