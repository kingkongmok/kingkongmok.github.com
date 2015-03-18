#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: tomcat200.pl
#
#        USAGE: ./tomcat200.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 03/10/2015 09:48:57 AM
#     REVISION: ---
#===============================================================================

#use warnings FATAL => qw(uninitialized);

use warnings;
use strict;
use IO::Handle;
use File::Temp "tempfile";

# tomcat yesterday log location
#open my $fh_log1 , "zcat /tmp/test/1/http_status_code.log.1.gz | "  || die $!;
#open my $fh_log2 , "zcat /tmp/test/4/http_status_code.log.1.gz | "  || die $!;
#open my $fh_log3 , "zcat /tmp/test/3/http_status_code.log.1.gz | "  || die $!;
#open my $fh_log4 , "zcat /tmp/test/5/http_status_code.log.1.gz | "  || die $!;
open my $fh_log1 , "zcat /home/logs/1_mmlogs/crontabLog/http_status_code.log.1.gz | "  || die $!;
open my $fh_log2 , "zcat /home/logs/4_mmlogs/crontabLog/http_status_code.log.1.gz | "  || die $!;
open my $fh_log3 , "zcat /home/logs/3_mmlogs/crontabLog/http_status_code.log.1.gz | "  || die $!;
open my $fh_log4 , "zcat /home/logs/5_mmlogs/crontabLog/http_status_code.log.1.gz | "  || die $!;
#
# output for png and txt header
my @serverList = qw( 42.1 42.2 42.3 42.5 );
#
#
#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------
# yesterday output
chomp(my $yesterday = `date +%F -d -1day`);
#
# 24 hour, don't edit
#my @date_str = push @date_str, 
my @hourArray = map{sprintf"%02i",$_}0..23 ;
my @minuteArray = map{sprintf"%02i", $_}0..59 ;
my @date_str ;


foreach my $hour ( @hourArray ) {
    foreach my $minute ( @minuteArray ) {
        push @date_str ,"$hour:$minute" ;
    }
}


#===  FUNCTION  ================================================================
#         NAME: getTomcatLineArray
#      PURPOSE: 
#   PARAMETERS: log filehandle
#      RETURNS: tomcat 77{11,22,33,44} pv (10k) array by hourly
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getTomcatLineArray {
    my  ( $fh ) = @_;
    my %H;
    while ( <$fh> ) {
        if ( /^\d/ ) {
            my @F = split ;
            $H{$F[0]}=int($F[2]);
        }
    }
    my @dateOut = map{ $H{$_} } sort{$a cmp $b} keys %H;
    return \@dateOut;
} ## --- end sub getTomcatLineArray


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
for my $k (0..(~~@date_str-1)) {
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
open my $P, "|-", "/home/moqingqiang/local/gnuplot-5.0.0/bin/gnuplot" or die;
printflush $P qq[
        set key top left title "TotalMaxValue=$maxValue at $maxTime"
        set title "$yesterday 2XX Minutely Report"
        set xdata time
        set timefmt "%H:%M"
        set format x "%H:%M"
        set xtics rotate
        set yrange [0:] noreverse
        set xlabel 'Time: every minute'
        set ylabel 'Http 2xx stat code'
        set terminal png giant size 1000,500 
        set output "/tmp/tomcat200.png"
        plot "$N" using 1:2 title '$serverList[0]' with lines linecolor rgb "red" linewidth 1.5,\\
             "$N" using 1:3 title '$serverList[1]' with lines linecolor rgb "blue" linewidth 1.5,\\
             "$N" using 1:4 title '$serverList[2]' with lines linecolor rgb "orange" linewidth 1.5,\\
             "$N" using 1:5 title '$serverList[3]' with lines linecolor rgb "brown" linewidth 1.5,\\
];
close $P;


`cp $N "/home/moqingqiang/tmp/$yesterday-200.txt"` ;
`cp "/tmp/tomcat200.png" "/home/moqingqiang/tmp/$yesterday-200.png"` ;
