---
layout: post
title: "delete elements from a array"
category: perl
tags: [delete, elements, index, array, perl]
---

可以使用grep来获取元素位于数组的位置（indexes），然后通
过for和splice来删除相应元素，但注意必须使用reverse来反转一下indexes的顺序，否则会误删除元素。

<pre lang="perl">
my@array=qw/1 2 3 1 2 3/;
my@index=grep{$array[$_]==3}0..$#array;
foreach ( reverse@index ) {
    splice(@array,$_,1);
}
print for @array;
</pre>

---display---
1
2
1
2
