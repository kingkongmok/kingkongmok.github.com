---
layout: post
title: "php prefork mpm"
category: linux
tags: [php, fpm, apache, mpm, prefork]
---

今天查询一个关于php进程的时候发现这个关于[php进程文章](http://stackoverflow.com/questions/10678542/php5-fpm-children-and-requests).

可以从大神的回复中得知apache php-mod使用了prefork的方式来控制进程（注意是进程不是线程。you are using the prefork mpm for apache. So every concurrent http requests is handled by a distinct httpd process (no threads).）。

所以，使用这种模式的话必须控制spawn的个数，免得fork太多进程了。控制MaxClients。

而相对的，是使用apache worker的方式，也就是nginx的调用fcgi的模式，这个可以管理pool of threads.
