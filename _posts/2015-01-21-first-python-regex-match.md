---
layout: post
title: "first python regex match"
category: python
tags: [regex, match]
---

今天要搞一下简单的python

### 代码
原来的actionUrl调整了，需要调整regex来匹配之。

```
if re.search(r'RequestTime',requestTime):
    #interfaceName = actionUrl.split('=')[2]
    interfaceName = re.search(r'(?<=func=)\S+?(?=\&)',actionUrl).group(0)
```

但上面这个代码跑出来会有下面的异常：

```
AttributeError: 'NoneType' object has no attribute 'group'
```

### 解决方法

[这里提到需要做一个if](http://stackoverflow.com/questions/22681763/attributeerror-nonetype-object-has-no-attribute-group)

```
if re.search(r'RequestTime',requestTime):
    #interfaceName = actionUrl.split('=')[2]
                    #match = re.search(r'(?<=func=)\S+?(?=\&)',actionUrl)
                    match = re.search(r'(?<=func=)[^&]+',actionUrl)
                    if match:
                        interfaceName = match.group(0)
```

这样后就正常了。
