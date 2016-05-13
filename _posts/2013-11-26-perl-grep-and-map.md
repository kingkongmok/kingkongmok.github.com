---
layout: post
title: "perl grep and map"
category: perl
tags: [perl, map, grep]
---

### grep更换数组的值

<pre lang="perl" line="24">
my      @array = qw/1 2 3 4 5 1a 2b 3c 4d 5e a b c d e /;
my      @newarray = grep { s/a/A/g, $_ }  @array;

foreach my $line ( grep /a/i, @newarray ) {
    print "$line\n" ;
}
</pre>

##结果如下：

<code>
perl test.pl
1A
A
</code>

### 获取10个值的rand 10数组：

```
my @a =  map {int rand 10} 0..9 ;
print @a;
```

### 获取10个值的rand 10的aoa：

```
use Data::Dumper;
my @aoa = map {  [ map {int rand 10} 0..9] } 0..9 ;
print Dumper \@aoa;
```

