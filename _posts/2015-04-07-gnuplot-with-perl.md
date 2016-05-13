---
layout: post
title: "perl使用gnuplot绘图"
category: linux
tags: [gnuplot, perl]
---


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
        set ylabel 'Http 2XX stat code'
        set terminal png giant size 1000,500 
        set output "/tmp/tomcat200.png"
        plot "$N" using 1:2 title '$serverList[0]' with lines linecolor rgb "red" linewidth 1.5,\\
             "$N" using 1:3 title '$serverList[1]' with lines linecolor rgb "blue" linewidth 1.5,\\
             "$N" using 1:4 title '$serverList[2]' with lines linecolor rgb "orange" linewidth 1.5,\\
             "$N" using 1:5 title '$serverList[3]' with lines linecolor rgb "brown" linewidth 1.5,\\
];
close $P;
```

### Chart::Gnuplot

#### font error 

```
Could not find/open font when opening font "arial", using internal non-scalable font
gdImageStringFT: Could not find/open font while printing string nginx status with font Times-Roman
```

[解决方法](https://bugzilla.redhat.com/show_bug.cgi?id=537960)

```
export GDFONTPATH=/usr/share/fonts/liberation
export GNUPLOT_DEFAULT_GDFONT=LiberationSans-Regular
```

#### example

```
    my @dates_toDraw = sort keys  %timeReq;
    # set plot format below.
    my $chart = Chart::Gnuplot->new(  
        output => "/tmp/$outputname.png",
        terminal => 'png',
        imagesize => "1000,500", 
        key => 'top left',   # location
        title => {
            text => 'nginx requests',
            font => "LiberationMono-Regular, 20",
        },
        grid => 'on',
        timeaxis => "x",   # set x axis as time format.
        xlabel => 'Time: every minute',
        ylabel => 'request(10K)',
    );
    # #
    my @dataSetArray;
    for ( my $iterator=0; $iterator<$#dates_toDraw+1; $iterator++ ) {
        $dataSetArray[$iterator] = Chart::Gnuplot::DataSet->new(
            xdata   => \@x,
            ydata   => [@{$timeReq{$dates_toDraw[$iterator]}}{sort keys
                %{$timeReq{$dates_toDraw[$iterator]}}}],
            style   => 'lines',
            title => "$dates_toDraw[$iterator]",
            timefmt => '%H:%M',      # input time format
        );
    }
    $chart->plot2d(@dataSetArray); # draw
```
