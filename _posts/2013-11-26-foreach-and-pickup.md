---
layout: post
title: "foreach and pickup 百人间隔轮回游戏"
category: perl
tags: [foreach, pickup]
---


##练习题
有一百个人，分别从0一直到99。现在有人拿枪从第一个开始杀，每杀一个跳过一个，一直到一轮完成。接着在活着的人里面再次杀第一个，间隔一个再枪毙一个，请问最后活着的是这一百个人里的第几个人？ 


```
my @a = 1..100;
while ( ~~@a>1 ) {
    my $i ; 
    @a = grep {$i++ % 2 == 1 } @a ;
}
print @a ;
```

**out put**
**64**
