---
layout: post
title: "perl字符处理问题"
category: perl 
tags: [utf8, charset, perl, encode]
---
{% include JB/setup %}

### [来源地址](http://www.gipsky.com/modules/article/view.article.php?1155/c0)

### perl internal form

在Perl看来, 字符串只有两种形式. 一种是octets, 即8位序列, 也就是我们通常说的字节数组. 另一种utf8编码的字符串, perl管它叫string. 也就是说: Perl只熟悉两种编码: Ascii(octets)和utf8(string).

## utf8 flag

```
use Encode;
use strict;
my $str = "中国";
Encode::_utf8_on($str);
print length($str) . "\n";
Encode::_utf8_off($str);
print length($str) . "\n";

__DATA__

2
6
```

使用Encode模块的_utf8_on函数和_utf8_off函数来开关字符串"中国"的utf8 flag. 可以看到, utf8 flag打开的时候, "中国"被当成utf8字符串处理, 所以其长度是2. utf8 flag关闭的时候, "中国"被当成octets(字节数组)处理, 出来的长度是6(我的编辑器用的是utf8编码, 假如你的编辑器用的是gb2312编码, 那么长度应该是4).


```
use Encode;
use strict;
my $a = "china----中国";
my $b = "china----中国";
Encode::_utf8_on($a);
Encode::_utf8_off($b);
$a =~ s/\W //g;
$b =~ s/\W //g;
print $a, "\n";
print $b, "\n";

__DATA__

Wide character in print at unicode.pl line 10.
china中国
china
```

结果第一行是一条警告, 这个我们稍后再讨论. 结果的第二行说明, utf8 flag开启的情况下, 正则表达式中的\w能够匹配中文, 反之则不能.

如何确定一个字符串的utf8 flag是否已开启? 使用Encode::is_utf8($str). 这个函数并不是用来检测一个字符串是不是utf8编码, 而是仅仅看看它的utf8 flag是否开启.


## unicode转码

perl错误地拆解了字符. 严重的时候, perl会报警, 说某个字节不是合法的utf8内码，这个通常是错误的编码造成，假如你有一个字符串"中国", 它是gb2312编码的. 假如它的utf8 flag是关闭的, 它就会被当成octets来处理, length()会返回4, 这通常不是你想要的. 而假如你开启它的utf8 flag, 则它会被当做utf8编码的字符串来处理. 由于它本来的编码是gb2312的, 不是utf8的, 这就可能导致错误发生. 
解决的方法很显然, 假如你的字符串本来不是utf8编码的, 应该先把它转成utf8编码, 并且使它的utf8 flag处于开启状态. 对于一个gb2312编码的字符串, 你可以使用

```
$str = Encode::decode("gb2312", $str);
```

来将其转化为utf8编码并开启utf8 flag. 假如你的字符串编码本来就是utf8, 只是utf8 flag没有打开, 那么你可以使用以下三种方式中的任一种来开启utf8 flag:

```
$str = Encode::decode_utf8($str);
$str = Encode::decode("utf8", $str);
Encode::_utf8_on($str);
```

最后一种方式效率最高, 但是官方不推荐. 以下划线开头的函数是内部函数, 出于礼貌, 一般不从外部调用.


## 字符串连接

```.``` 是字符串连接操作符. 连接两个字符串时, 假如两个字符串的utf8 flag都是Off, 那么结果字符串也是Off. 假如其中任何一个字符串的utf8 flag是On的话, 那么结果字符串的utf8 flag将是On. 连接字符串并不会改变它们原来的编码, 所以假如你把两个不同编码的字符串连在一起, 那么以后不管对这个字符串怎么转码, 都总会有一段是乱码. 这种情况一定要避免, 连接两个字符串之前应该确保它们编码一致. 如有必要, 先进行转码, 再连接字符串.


## perl unicode编程基本原则

 1)把它的编码转换成utf8; 2)开启它的utf8 flag


### INPUT

为了应用上面说到的基本原则, 我们首先要知道字符串本来的编码和utf8 flag开关情况, 这里我们讨论几种情况.

命令行参数和标准输入. 从命令行参数或标准输入(STDIN)来的字符串, 它的编码跟locale有关. 假如你的locale是zh_CN或zh_CN.gb2312, 那么进来的字符串就是gb2312编码, 假如你的locale是zh_CN.gbk, 那么进来的编码就是gbk, 假如你的编码是zh_CN.UTF8, 那进来的编码就是utf8. 不管是什么编码, 进来的字符串的utf8 flag都是关闭的状态.

你的源代码里的字符串. 这要看你编写源代码时用的是什么编码. 在editplus里, 你可以通过"文件"->"另存为"查看和更改编码. 在linux下, 你可以cat一个源代码文件, 假如中文正常显示, 说明源代码的编码跟locale是一致的. 源代码里的字符串的utf8 flag同样是关闭的状态.

假如你的源代码里含有中文, 那么你最好遵循这个原则: 1) 编写代码时使用utf8编码, 2)在文件的开头加上use utf8;语句. 这样, 你源代码里的字符串就都会是utf8编码的, 并且utf8 flag也已经打开.

从文件读入. 这个毫无疑问, 你的文件是什么编码, 读进来就是什么编码了. 读进来以后, utf8 flag是off状态.

抓取网页. 网页是什么编码就是什么编码, utf8 flag是off状态. 网站的编码可以从响应头里或者html的

```
http://www.sina.com.cn";
eval {my $str2 = $str; Encode::decode("gbk", $str2, 1)};
print "not gbk: $@\n" if $@;

eval {my $str2 = $str; Encode::decode("utf8", $str2, 1)};
print "not utf8: $@\n" if $@;

eval {my $str2 = $str; Encode::decode("big5", $str2, 1)};
print "not big5: $@\n" if $@;

__DATA__

not utf8: utf8 "\xD0" does not map to Unicode at /usr/local/lib/perl/5.8.8/Encode.pm line 162.
not big5: big5-eten "\xC8" does not map to Unicode at /usr/local/lib/perl/5.8.8/Encode.pm line 162.
```

我们给decode函数传递了第三个参数, 要求有异常字符的时候报错. 我们用eval捕捉错误, 转码失败说明字符串本来不是这种编码. 另外注重我们每次都把$str拷贝到$str2, 这是因为decode第三个参数为1时, decode以后, 传给它的字符串参数(第二个参数会被清空). 我们拷贝一下, 这样每次被清空的都是$str2, $str不变.

来看结果, 既然不是utf8, 也不是big5, 那就应该是gbk了. 对于其他不知编码的字符串, 也可以使用这种方法来猜. 不过因为几种编码的内码范围都差不多, 所以假如字符串比较短, 就可能出不了异常字符, 所以这个方法只适用于大段的文字.


### OUTPUT

字符串在程序内被正确地处理后, 要展现给用户. 这时我们需要把字符串从perl internal form转化成用户能接受的形式. 简单地说, 就是把字符串从utf8编码转换成输出的编码或表现界面的编码. 这时候, 我们使用$str = Encode::encode('charset', $str);. 同样可以分为几种情况.

1) 标准输出. 标准输出的编码跟locale一致. 输出的时候utf8 flag应该关闭, 不然就会出现我们前面看到的那行警告:

```
Wide character in print at unicode.pl line 10.
```

2) GUI程序. 这个应该是不用干什么, utf8编码, utf8 flag开启就行. 没有实际测试过.

3) 做http post. 看网页表单要求什么编码. utf8 flag开或关无所谓, 因为http post发送出去的只是字符串中的数据部分, 不管utf8 flag.

## PerlIO

PerlIO为我们的输入/输出转码提供了便利. 它可以针对某个文件句柄, 输入的时候自动帮你转码并开启utf8 flag, 输出的时候, 自动帮你转码并关闭utf8 flag. 假设你的终端locale是gb2312, 看下面的例子:

```
use strict;
binmode(STDIN, ":encoding(gb2312)");
binmode(STDOUT, ":encoding(gb2312)");
while (<>) {
chomp;
print $_, length, "\n";
}

__DATA__

中国2
```

这样我们就省去了输入和输出时转码的麻烦. PerlIO可以作用于任何文件句柄, 具体请参考perldoc PerlIO.

### API

都是Encode模块的:
$octets = encode(ENCODING, $string [, CHECK]) 把字符串从utf8编码转成指定的编码, 并关闭utf8 flag.
$string = decode(ENCODING, $octets [, CHECK]) 把字符串从其他编码转成utf8编码, 并开启utf8 flag, 不过有个例外就是, 假如字符串是仅仅ascii编码或EBCDIC编码的话, 不开启utf8 flag.
is_utf8(STRING [, CHECK]) 看看utf8 flag是否开启. 假如第二个参数为真, 则同时检查编码是否符合utf8. 这个检测不一定准确, 跟decode方式检测效果一样.
_utf8_on(STRING) 打开字符串的utf flag
_utf8_off(STRING) 关闭字符串的utf flag

最后两个是内部函数, 不推荐使用.

参考perldoc Encode.
