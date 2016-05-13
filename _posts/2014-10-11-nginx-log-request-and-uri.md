---
layout: post
title: "nginx log"
category: linux
tags: [nginx, log, uri]
---


## 默认情况下的logformat

```
    log_format main
        '$remote_addr - $remote_user [$time_local] '
        '"$request" $status $bytes_sent '
        '"$http_referer" "$http_user_agent" '
        '"$gzip_ratio"';
```

### `$request`会有以下效果

```
127.0.0.1 - - [11/Oct/2014:09:13:59 +0800] "GET /adsfsadf?dfasdf=asdfasdf&dsafdfsda=asdf&ddf=asdfa&dfsdf=sd HTTP/1.1" 502 352 "-" "curl/7.36.0" "-"
```

### `$request`修改为`$uri`

```
127.0.0.1 - - [11/Oct/2014:09:19:29 +0800] "/adsfsadf" 502 352 "-" "curl/7.36.0" "-"
```

作用就见仁见智了。


## 修改有关http_referer的方法

http_referer 是用于记录**Referrer Page**的信息，如果需要修改不要后面的**?**，可以这样

```
14 
15     log_format main
16         '$remote_addr - $remote_user [$time_local] '
17         '"$request" $status $bytes_sent '
18         #'"$http_referer" "$http_user_agent" '
19         '"$log_referer" "$http_user_agent" '
20         '"$gzip_ratio"';
21 

66         location / {
67             proxy_pass http://tomcat ;
68             if ($http_referer ~* "^(.*)\?" ) {
69                 set $log_referer $1 ;
70             }
71 
72         }
```

```bash
kk@ins14 ~ $ curl 'localhost/adsfsadf?dfasdf=asdfasdf&dsafdfsda=asdf&ddf=asdfa&dfsdf=sd' -e "www.baidu.com/index.html?a=1&b=2"

127.0.0.1 - - [11/Oct/2014:14:07:29 +0800] "GET /adsfsadf?dfasdf=asdfasdf&dsafdfsda=asdf&ddf=asdfa&dfsdf=sd HTTP/1.1" 502 352 "www.baidu.com/index.html" "curl/7.36.0" "-"
```
