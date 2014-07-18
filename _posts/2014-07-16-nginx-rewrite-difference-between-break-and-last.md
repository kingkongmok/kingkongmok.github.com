---
layout: post
title: "nginx rewrite difference between break and last"
category: linux
tags: [nginx, rewrite, last, break]
---
{% include JB/setup %}

[这里有明确说明](http://serverfault.com/questions/131474/nginx-url-rewriting-difference-between-break-and-last)

You may have different sets of rewrite rules for different locations. When rewrite module meets last, it stops processing the current set and the rewritten request is passed once again to find the appropriate location (and the new set of rewriting rules). If the rule ends with break, the rewriting also stops, but the rewritten request is not passed to another location.

That is, if there are two locations: loc1 and loc2, and there's a rewriting rule in loc1 that changes loc1 to loc2 AND ends with last, the request will be rewritten and passed to location loc2. If the rule ends with break, it will belong to location loc1.

简单总结，`last`会继续匹配下一个location，
`last`不会。

也有同学提出不同观点：
last 停止处理后续rewrite指令集，然后对当前重写的新URI在rewrite指令集上重新查找。
break 停止处理后续rewrite指令集，并不在重新查找,但是当前location内剩余非rewrite语句和location外的的非rewrite语句可以执行。
redirect 如果replacement不是以http:// 或https://开始，返回302临时重定向
permant 返回301永久重定向
