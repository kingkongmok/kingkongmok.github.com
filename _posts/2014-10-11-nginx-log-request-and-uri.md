---
layout: post
title: "nginx log request and uri"
category: linux
tags: [nginx, log, uri]
---
{% include JB/setup %}


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
