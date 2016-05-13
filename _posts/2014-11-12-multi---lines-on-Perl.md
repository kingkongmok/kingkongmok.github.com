---
layout: post
title: "Multi-lines on Perl 多行文本的Perl处理"
category: perl
tags: [count, while, txt, multi]
---

记录一下perl的多行正则用法

### count the words in multi-line

```perl
$_=" Apple banana orange pear
Pear apple apple pear
 Banana banana apple orange" ;

my%h;
while (/(\w+)(?=\s)/igsm ) {
    $h{lc$1}++ ;
}

while ( (my$k,my$v)=each%h ) {
    print "$k\t$v\n"
}
```

### $/ $INPUT_RECORD_SEPARATOR

```perl
open my $fh , "test.txt" or die $!; 

$/=undef ;
while (<$fh>) {    
    while ( m{ \b(\w\S+)(\s+\1)+\b}xg) {
        print "dup word '$1' at paragraph $.\n";
    } 
}
```


##换行的字符串分类

qq群里面有朋友问如何使得有大小写并有换行的字符串分类并 列明数量，以下是方法。

<pre lang="perl">
#!/usr/bin/perl
use strict;
use warnings;

$_=" Apple banana orange pear
 Pear apple apple pear
 Banana banana apple orange" ;

my%h;
while (/(\w+)(?=\s)/igsm ) {
    $h{lc$1}++ ;
}

while ( (my$k,my$v)=each%h ) {
    print "$k\t$v\n"
}
</pre>


<code>
banana  3
apple   4
orange  1
pear    3
</code>


### match modifers


http://www.perlmonks.org/?node_id=940352

```
/i Ignore alphabetic case distinctions (case-insensitive).
/s Let . also match newline.
/m Let ^ and $ also match next to embedded \n.
/x Ignore (most) whitespace and permit comments in pattern.
/o Compile pattern once only.
/p Preserve ${^PREMATCH}, ${^MATCH}, and ${^POSTMATCH} variables.
/d Dual ASCII–Unicode mode charset behavior (old default).
/a ASCII charset behavior.
/u Unicode charset behavior (new default).
/l The runtime locale’s charset behavior (default under use locale).
```

```
$s = "foo\nfoot\nroot";
$s =~ /^foo/g;           # matches only the first foo
$s =~ /^foo/gm;          # matches both foo
$s =~ /f.*t/g;           # matches only foot
$s =~ /f.*t/gs;          # matches foo\nfoot\nroot
$s =~ /f.*?t/gs;         # matches foo\nfoot
$s =~ /^foot.*root$/g;   # doesn't match
$s =~ /^foot.*root$/gm;  # doesn't match
$s =~ /^foot.*root$/gs;  # doesn't match
$s =~ /^foot.*root$/gms; # matches foot\nroot
```

http://perl.active-venture.com/pod/perlfaq6.html
http://pleac.sourceforge.net/pleac_perl/patternmatching.html


### 删除头尾10字节

```
cat file.txt | perl -0777pe 's/^.{10}//gs; s/.{10}$//gs'
```

### 统计网卡和ip

```
ifconfig | perl -MData::Dumper -00ne 'while(/(^\w+):.*inet (\S+)/gsm){$h{$1}=$2}}{print Dumper \%h'
```
