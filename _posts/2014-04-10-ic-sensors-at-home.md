---
layout: post
title: "ic sensors at home"
category: linux
tags: [lm_sensors, sensors, kernel, modules]
---
{% include JB/setup %}

在公司和笔记本T510都是使用似乎是intel的模块coretemp,[操作方法](https://wiki.gentoo.org/wiki/Lm_sensors).
但是家里面的旧945主板就麻烦点，
后来使用sensors-detect时发现一个关键词，安装相应驱动后就正常了。

{% highlight bash %}
Now follows a summary of the probes I have just done.
Just press ENTER to continue: 

Driver w83627ehf:
  * ISA bus, address 0x290
    Chip Winbond W83627EHF/EF/EHG/EG Super IO Sensors (confidence: 9)

{% endhighlight %}
编译w83627ehf.ko后正常。
