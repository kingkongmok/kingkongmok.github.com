---
layout: post
title: "sitemap.txt a dynamic page"
category: web
tags: [sitemap.txt, atom.xml, dynamic, _config, production_url ]
---
{% include JB/setup %}

## sitemap.txt 终于能生成正常
**sitemap.txt atom.xml 是由production_url生产的静态页**
之前一直不断尝试修改_config文件和sitemap.txt文件，但一直无法看到正常的路径。原因是太高估自己能避免缓存了。忘记txt文件也可能是动态文件,可以由服务端缓存的。碰到这个情况，以后要加?来去尝试。

```sh
kk@debian:~/Documents/kingkongmok.github.com$ curl www.datlet.com/sitemap.txt?sdfas

http://www.datlet.com/archive.html
http://www.datlet.com/index.html
http://www.datlet.com/pages.html
http://www.datlet.com/tags.html
http://www.datlet.com/categories.html
http://www.datlet.com/atom.xml
http://www.datlet.com/sitemap.txt

http://www.datlet.com/web/2013/11/06/hello-world-hello-git
http://www.datlet.com/lessons/2011/12/29/jekyll-introduction
```
