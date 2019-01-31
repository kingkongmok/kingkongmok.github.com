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
cd /tmp/website/module/
enca -L zh -x utf8 *
rm -f index.php
mkdir txt
for i in `grep 第.*章 index.php* -l ` ; do mv "$i" txt ; done
cd txt
perl-rename 's/.*/sprintf"%02d.txt",++$i/e' * -i
for i in *txt ; do perl -i.bak -00ne 'while(/\<pre\>(.*)\<\/pre\>/gsm){print $1}' "$i"; done
cat *.txt > all.txt
perl -i.bak -pe 's/\r\n//' all.txt
perl -i.sp -pe 's/　　/\n　　/g; s/    /\n　　/g' all.txt
```
