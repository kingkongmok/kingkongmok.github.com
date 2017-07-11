---
layout: post
title: "smbpasswd script"
category: linux
tags: [samba, smbuser]
---

万能的[stackoverflow](http://stackoverflow.com/questions/12009/piping-password-to-smbpasswd)给出的答案，虽然不太满意因为没有k-v可以记录以及不可以自动自动辨别用户组。但鉴于还是需要辨别用户组，bashhist其实以及能较好的记录信息了。所以还是先用着。

```
echo -ne "$PASS\n$PASS\n" | smbpasswd -a -s $LOGIN
```
