---
layout: post
title: "sprintf and printf"
category: perl
tags: [printf, sprintf]
---

sprintf通常需有e在s///后面，例如

```
while ( <$fh> ) {
    print s/.*/sprintf"%02d",$i++/re;
}
```

而printf可以直接使用例如

```
while ( <$fh> ) {
    printf "%02d\n",$i++;
}
```

### 16进制显示

```
 perl -e 'printf"%04x\n",$_ for 1..2**16'
```
