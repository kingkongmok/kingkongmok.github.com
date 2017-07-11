---
layout: post
title: "Opening and Reading line by line from 2 files 两文本各行读取文件"
category: perl
tags: [open, 2files, line by line]
---

```
perl -e 'open FHA,"<a"; open FHB,"<b"; while(1){$x=<FHA>;$y=<FHB>; $x||last;$y||last ; print $x, $y }'
```

