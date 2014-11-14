---
layout: post
title: "extract ZIP with non UTF filename encoding 解压非UTF压制的zip文件"
category: linux
tags: [unzip, utf8, gbk, 7z, convmv]
---
{% include JB/setup %}

zip软件对于文件名似乎没有rar和7z处理好，会出现Linux解压非utf8的文件乱码情况，[这里博客](http://yuanjie.name/entry/how-to-extract-zip-with-non-utf-filename-encoding-in-linux)介绍处理unzip乱码的解决方法：

```bash
env LANG=GBK 7z x windows_zipped.filename
ls | xargs -i convmv -f GBK -t utf8 {}
ls | xargs -i convmv -f GBK -t utf8 {} --notest
```
