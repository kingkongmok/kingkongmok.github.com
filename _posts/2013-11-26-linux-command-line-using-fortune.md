---
layout: post
title: "forumn command"
category: linux
tags: [command, fortune]
---

##fortune

fortune能让枯燥的terminal生色。会产生随机的语录。结合co
wsay会有不错的动漫效果。

##安装

<pre lang="bash">
sudo apt-get install fortune fortune-mod 
</pre>


##如果需要每次启动bash的时候显示，就这样添加到.bashrc

```
cat << EOF >> ~/.bashrc
if [ -x /usr/games/fortune ]; then
    /usr/games/fortune -s | cowsay
fi
EOF
```


##可以自己做词库

```
perl -i.bak -pe '$\="%\n"' cultureRevolution.txt
strfile cultureRevolution.txt
udo mv cultureRevolution.* /usr/share/games/fortunes
```

