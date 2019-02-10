---
title: "novel download"
layout: post
category: perl
---

下载

```
proxychains wget -P /tmp --user-agent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)" -r -l1 'https://website/module/index.php'
```

```
cd /tmp/www*/bbs*/
enca -L zh -x utf8 *
rm -f index.php
mkdir txt
for i in `grep 送交者 index.php* -l ` ; do cp "$i" txt ; done
cd txt
perl-rename 's/.*/sprintf"%02d.txt",++$i/e' * -i
for i in *txt ; do perl -i.bak -00ne 'while(/\<pre\>(.*)\<\/pre\>/gsm){print $1}' "$i"; done
cat *.txt > all.txt
perl -i.bak -pe 's/<font color=#\w+?>\w+?\.\w+<\/font><p><\/p>//g; s/\r\n//g; s/　　/\n　　/g; s/    /\n　　/g' all.txt
perl -i -ne 'print unless /^[\s　]+\r?$/' all.txt
```
