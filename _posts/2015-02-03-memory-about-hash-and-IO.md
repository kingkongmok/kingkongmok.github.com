---
layout: post
title: "perl在读大文件时的hash和IO和内存占用"
category: perl
tags: [perl, hash, memory, IO]
---

## hash的内存

在日志分析中出现了较大内存占用的情况，需要简单分析内存使用情况，有同学推荐使用***[Devel::Size](http://www.perlmonks.org/?node_id=51226)***

### Devel::Size

```perl
use Data::Dumper;
use Devel::Size qw/total_size size/;

my ( $filename ) = @ARGV ;
open my $fileout, "> /tmp/fileout";
open my $fh , "< $filename";
my %H ;

while ( <$fh> ) {
    while ( /\s(\S+)/g ) {
        $H{$1}++;
    }
}

print $fileout Dumper \%H;
close $fileout  ;
print "file size with Dumper", +(stat "/tmp/fileout")[7] , "\n";

print "hash total_size ", total_size(\%H), "\n";
print "hash size ", size(\%H), "\n";
```

用这个可以简单测试所指文件的单词hash的***print Dumper***, ***total_size***，和***size***；  

```
$ perl  test.pl ~/.bashrc
file size 6124
hash total_size 23227
hash size 17515

$ perl  test.pl ~/.muttrc
file size 5023
hash total_size 18421
hash size 14125

$ perl  test.pl ~/.inputrc 
file size 155
hash total_size 563
hash size 467
```

### 结论

hash占用的内存不多，大多在于key/value的字符串。基本不用考虑。

## IO 和 内存

这里有[IO](http://www.troubleshooters.com/codecorn/littperl/perlfile.htm)的测试,他推荐的方法使用Sip。
但我在虚拟机测试的结果和他稍不同：


```
$ perl ./test.pl 
Starting sip
End sip
Starting array
buildarray's @line memory 616758384
End array
Starting slurp
slurp's @line memory 614763136
End slurp
Starting readlinetest
readlinetest's @line memory 609986525
End readlinetest
Starting <>
<>'s @line memory 609986525
End <>
Sip time is 5 seconds
Array time is 4 seconds
Slurp time is 62 seconds
readlinetest time is 7 seconds
<> time is 6 seconds
```

### 结论

在大日志分析的时候，注意要使用Sip的方式来读取，减少使用@lines以免耗尽内存。如果是小文件，应当是buildarray的方式快捷和简单。
