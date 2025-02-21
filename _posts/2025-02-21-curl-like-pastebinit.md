---
layout: post
title: "curl like pastebinit"
category: linux
tags: [pastebinit, bpaste, pastebin]
---


使用curl命令上传文本到pastebin类服务，您需要构造一个HTTP POST请求。不同的pastebin服务提供商会有不同的API和要求。这里我以https://paste.c-net.org/ 为例来说明如何使用curl命令行工具上传一段文本，并获取分享链接。

假设我们要上传的内容保存在example.txt文件中，您可以使用如下命令：


```
curl -X POST -s -d "text=$(cat example.txt)" https://paste.c-net.org/
```
