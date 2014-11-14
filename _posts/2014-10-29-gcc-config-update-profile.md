---
layout: post
title: "gcc-config on gentoo"
category: linux
tags: [gcc, profile, update, emerge]
---
{% include JB/setup %}

## 在升级gcc后，发现用emerge出问题：

["media-libs/lcms-2.6-r1" STDOUT](https://bpaste.net/show/7ef0633bcf7f)

["media-libs/lcms-2.6-r1" emerge info](https://bpaste.net/show/1d6aed089d24)

### 运行[gcc-config](http://wiki.gentoo.org/wiki/Upgrading_GCC)解决

```bash
kk@ins14 ~ $ sudo gcc-config -l
 * gcc-config: Active gcc profile is invalid!

  [1] x86_64-pc-linux-gnu-4.8.3
  kk@ins14 ~ $ sudo gcc-config 1
   * Switching native-compiler to x86_64-pc-linux-gnu-4.8.3 ...
   >>> Regenerating /etc/ld.so.cache...                                                                                 [ ok ]

    * If you intend to use the gcc from the new profile in an already
     * running shell, please remember to do:

      *   . /etc/profile
```

终结来说，需要手册上perl和python两个升级后的处理脚本遇到GCC升级，还得设置gcc-config
