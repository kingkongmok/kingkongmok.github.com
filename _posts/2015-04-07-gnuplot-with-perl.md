---
layout: post
title: "perl使用gnuplot绘图"
category: linux
tags: [gnuplot, perl]
---
{% include JB/setup %}

### 正常的方法使用[Chart::Gnuplot](http://search.cpan.org/~kwmak/Chart-Gnuplot-0.23/lib/Chart/Gnuplot.pm)

但由于服务不太好支持cpan更新，所以要考虑直接执行gnuplot的命令


### gnuplot Demo

官方有个[参考](http://gnuplot.sourceforge.net/demo/), 可以参考Text options里面的方法。

### 自己的例子,不使用pm。

```

#-------------------------------------------------------------------------------
# $line是一个Array, 每分钟的访问数量
#-------------------------------------------------------------------------------
my $line1 = &getTomcatLineArray($fh_log1);
my $line2 = &getTomcatLineArray($fh_log2);
my $line3 = &getTomcatLineArray($fh_log3);
my $line4 = &getTomcatLineArray($fh_log4);


#-------------------------------------------------------------------------------
# use gnuplot command by shell, not PM
#-------------------------------------------------------------------------------
my($T,$N) = tempfile("/tmp/tomcat200-$$-XXXX", "UNLINK", 1);
print $T "#Time\t", join"\t",@serverList, "\t", "average", "\n" ;
my $maxValue = 0;
my $maxTime = 0;
#-------------------------------------------------------------------------------
# @date_str是一个Array，是全天60*24各个分钟数，
#-------------------------------------------------------------------------------
for my $k (0..(~~@date_str-1)) {
#-------------------------------------------------------------------------------
# 打印每分钟的各个Line的情况，并计算出最大值
#-------------------------------------------------------------------------------
    if ( defined $line1->[$k] && defined $line2->[$k] && $line3->[$k] && defined $line4->[$k] ) {
        if ( $maxValue < ($line1->[$k]+$line2->[$k]+$line3->[$k]+$line4->[$k]) ) {
            $maxValue = ($line1->[$k]+$line2->[$k]+$line3->[$k]+$line4->[$k]) ;
            $maxTime = $date_str[$k] ;
        }
        print $T $date_str[$k], "\t", 
            $line1->[$k], "\t", $line2->[$k], "\t", 
            $line3->[$k], "\t", $line4->[$k], "\t",
            int(($line1->[$k] + $line2->[$k] + $line3->[$k] + $line4->[$k])/4 ), "\n",
    }
}
close $T;
open my $P, "|-", "/usr/local/bin/gnuplot" or die;
printflush $P qq[
        set key top left title "TotalMaxValue=$maxValue(PV) at $maxTime"
        set title "$yesterday 2XX minutely" font "/usr/share/fonts/dejavu-lgc/DejaVuLGCSansMono-Bold.ttf, 20"
        set xdata time
        set timefmt "%H:%M"
        set format x "%H:%M"
        set xtics rotate
        set yrange [0:] noreverse
        set xlabel 'Time: every minute'
        set ylabel 'Http 5XX stat code'
        set terminal png giant size 1000,500 
        set output "/tmp/tomcat500.png"
        plot "$N" using 1:2 title '$serverList[0]' with lines linecolor rgb "red" linewidth 1.5,\\
             "$N" using 1:3 title '$serverList[1]' with lines linecolor rgb "blue" linewidth 1.5,\\
             "$N" using 1:4 title '$serverList[2]' with lines linecolor rgb "orange" linewidth 1.5,\\
             "$N" using 1:5 title '$serverList[3]' with lines linecolor rgb "brown" linewidth 1.5,\\
];
close $P;
```