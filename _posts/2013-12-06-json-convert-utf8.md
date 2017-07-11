---
layout: post
title: "json convert utf8"
category: linux
tags: [curl, linux, json, utf8, convert]
---

在使用curl抓取weibo的时候发现下载下来的东西是JSON，转换的方法[ 如下 ]( http://stackoverflow.com/questions/8795702/how-to-convert-uxxxx-unicode-to-utf-8-using-console-tools-in-nix )

##bash
```
echo -en "$(curl $URL)"
```

##perl

```
#!/usr/bin/perl

use strict;
use warnings;

binmode(STDOUT, ':utf8');

while (<>) {
    s/\\u([0-9a-fA-F]{4})/chr(hex($1))/eg;
    print;
}
```


##python
```
$ echo '["foo bar \u0144\n"]' | python -c 'import json, sys; sys.stdout.write(json.load(sys.stdin)[0].encode("utf-8"))'
```

##jdk
```
native2ascii -encoding UTF-8 -reverse src.txt dest.txt
```


