#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: tomcatHttpStatCodeAnalyze.pl
#
#        USAGE: ./tomcatHttpStatCodeAnalyze.pl  
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

use warnings; use strict;
use IO::Handle;
use File::Temp "tempfile";

# tomcat yesterday log location
my $fh_log1 = "/tmp/test/1/http_status_code.txt" ;
my $fh_log2 = "/tmp/test/2/http_status_code.txt" ;
my $fh_log3 = "/tmp/test/3/http_status_code.txt" ;
my $fh_log4 = "/tmp/test/4/http_status_code.txt" ;
#open my $fh_log1 , '-|', 'gzip', '-dc',  "/home/logs/1_mmlogs/crontabLog/tomcat_accesslog_line.log.1.gz" || die $! ;
#open my $fh_log2 , '-|', 'gzip', '-dc',  "/home/logs/4_mmlogs/crontabLog/tomcat_accesslog_line.log.1.gz" || die $! ;
#open my $fh_log3 , '-|', 'gzip', '-dc',  "/home/logs/3_mmlogs/crontabLog/tomcat_accesslog_line.log.1.gz" || die $! ;
#open my $fh_log4 , '-|', 'gzip', '-dc',  "/home/logs/5_mmlogs/crontabLog/tomcat_accesslog_line.log.1.gz" || die $! ;
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
    my  ( my $logLocation ) = @_;
    my %H;
    open my $fh , "$logLocation" ;
    my @lineArray = <$fh>;
    foreach my $line ( @lineArray ) {
        foreach my $dateString ( @date_str ) {
            $H{$dateString}=0;
                if ( $line =~ /$dateString/ ) {
                    my @F = split/\s+/,$line; 
                    $H{$dateString}+=$F[2];
                }
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
my($T,$N) = tempfile("/tmp/tomcatLineAnalyze-$$-XXXX", "UNLINK", 0);
print $T "#Time\t", join"\t",@serverList, "\t", "average", "\n" ;
my $maxValue = 0;
my $maxTime = 0;
for my $k (0..(~~@date_str-1)) {
    if ( $maxValue < ($line1->[$k]+$line2->[$k]+$line3->[$k]+$line4->[$k])/4 ) {
        $maxValue = ($line1->[$k]+$line2->[$k]+$line3->[$k]+$line4->[$k])/4 ;
        $maxTime = $k ;
    }
    print $T $date_str[$k], "\t", 
        $line1->[$k], "\t", $line2->[$k], "\t", 
        $line3->[$k], "\t", $line4->[$k], "\t",
        int(($line1->[$k] + $line2->[$k] + $line3->[$k] + $line4->[$k])/4 ), "\n",
}
my $TotalValue = $maxValue * 4 ; 
close $T;
#open my $P, "|-", "/home/moqingqiang/local/gnuplot-5.0.0/bin/gnuplot" or die;
open my $P, "|-", "gnuplot" or die;
printflush $P qq[
        set key top left title "MaxAverage=$maxValue with Total=$TotalValue at $maxTime:00"
        set title "$yesterday Tomcat AccessLog PV Hourly Report"
        set xdata time
        set timefmt "%H:%M"
        set format x "%H:%M"
        set xtics rotate
        set yrange [0:] noreverse
        set xlabel 'Time: Hourly'
        set ylabel '10k PageView'
        set terminal png giant size 1000,500 
        set output "/home/kk/Downloads/tomcatHttpStatCode.png"
        plot "$N" using 1:2 title '$serverList[0]' with lines linecolor rgb "red" linewidth 1.5,\\
             "$N" using 1:3 title '$serverList[1]' with lines linecolor rgb "blue" linewidth 1.5,\\
             "$N" using 1:4 title '$serverList[2]' with lines linecolor rgb "orange" linewidth 1.5,\\
             "$N" using 1:5 title '$serverList[3]' with lines linecolor rgb "brown" linewidth 1.5,\\
             "$N" using 1:6 title 'average' with lines linecolor rgb "green" linewidth 2.5,\\
];
close $P;


#`cp $N "/home/moqingqiang/tmp/$yesterday-pv.txt"` ;
#`cp "/tmp/tomcatPV.png" "/home/moqingqiang/tmp/$yesterday-pv.png"` ;

#-------------------------------------------------------------------------------
# mail -> mutt -> msmtp 
#-------------------------------------------------------------------------------
#my $systemCommand=q#mutt -e "my_hdr Content-Type: text/html" -s "# . qq#$yesterday# . q# TomcatLogPV" -a "/tmp/tomcatLogLine.png" moqingqiang@richinfo.cn < # . qq#$N# ;
#`$systemCommand`;
