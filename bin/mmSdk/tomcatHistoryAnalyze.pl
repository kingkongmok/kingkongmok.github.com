#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: tomcatHistoryAnalyze.pl
#
#        USAGE: ./tomcatHistoryAnalyze.pl  
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
#open my $fh_log1 , "/home/logs/1_mmlogs/crontabLog/tomcat_accesslog_line.log" ;
#open my $fh_log2 , "/home/logs/4_mmlogs/crontabLog/tomcat_accesslog_line.log" ;
#open my $fh_log3 , "/home/logs/3_mmlogs/crontabLog/tomcat_accesslog_line.log" ;
#open my $fh_log4 , "/home/logs/5_mmlogs/crontabLog/tomcat_accesslog_line.log" ;
#open my $fh_log1 , '-|', 'gzip', '-dc',  "/home/logs/1_mmlogs/crontabLog/tomcat_accesslog_line.log.1.gz" || die $! ;
#open my $fh_log2 , '-|', 'gzip', '-dc',  "/home/logs/4_mmlogs/crontabLog/tomcat_accesslog_line.log.1.gz" || die $! ;
#open my $fh_log3 , '-|', 'gzip', '-dc',  "/home/logs/3_mmlogs/crontabLog/tomcat_accesslog_line.log.1.gz" || die $! ;
#open my $fh_log4 , '-|', 'gzip', '-dc',  "/home/logs/5_mmlogs/crontabLog/tomcat_accesslog_line.log.1.gz" || die $! ;
open my $fh_log1 , "zcat /home/logs/1_mmlogs/crontabLog/tomcat_accesslog_line.log.*.gz |" || die $! ;
open my $fh_log2 , "zcat /home/logs/4_mmlogs/crontabLog/tomcat_accesslog_line.log.*.gz |" || die $! ;
open my $fh_log3 , "zcat /home/logs/3_mmlogs/crontabLog/tomcat_accesslog_line.log.*.gz |" || die $! ;
open my $fh_log4 , "zcat /home/logs/5_mmlogs/crontabLog/tomcat_accesslog_line.log.*.gz |" || die $! ;
#
# output for png and txt header
my @serverList = qw( 42.1 42.2 42.3 42.5 );
#
#
#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------
# yesterday output
chomp(my $date = `date +%F -d -1day`);
#
# 48 days, don't edit
#my @date_str = (0..23);
my $getDateCommand= q#for i in {48..1}; do date -d -${i}day +%F; done#;
chomp (my @date_str = `$getDateCommand`);

my %H ;


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
    my	( $fh )	= @_;
    my @logLine = <$fh> ;
    
    foreach my $date ( @date_str ) {
        $H{$date}=0;
        foreach my $line ( @logLine ) {
            if ($line =~ /$date.\d{2}\.log$/) {
                my @F = split " ",$line;
                 #show PV, 10k
                 $H{$date}+=int($F[0]/10_000);

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
my($T,$N) = tempfile("/tmp/tomcatLineAnalyze-$$-XXXX", "UNLINK", 1);
print $T "#Time\t", join"\t",@serverList, "\t", "average", "\n" ;
my $maxValue = 0;
my $yesterdayValue = $line1->[-1]+$line2->[-1]+$line3->[-1]+$line4->[-1];
my $maxTime = 0;
for my $k (0..(~~@date_str -1)) {
        if ( $maxValue < ($line1->[$k]+$line2->[$k]+$line3->[$k]+$line4->[$k])/4 ) {
            $maxValue = ($line1->[$k]+$line2->[$k]+$line3->[$k]+$line4->[$k])/4 ;
            $maxTime = $date_str[$k] ;
        }
        print $T $date_str[$k], "\t", 
                $line1->[$k], "\t", $line2->[$k], "\t", 
                $line3->[$k], "\t", $line4->[$k], "\t",
                int(($line1->[$k] + $line2->[$k] + $line3->[$k] + $line4->[$k])/4 ), "\n",
}
close $T;
my $TotalValue = $maxValue * 4 ; 
open my $P, "|-", "/home/moqingqiang/local/gnuplot-5.0.0/bin/gnuplot" or die;
printflush $P qq[
        set key top left title "TotalMaxAverage=$TotalValue(10k PV) at $maxTime, yesterday Total=$yesterdayValue(10k PV)"
        set title "$date PV daily compare" font "/usr/share/fonts/dejavu-lgc/DejaVuLGCSansMono-Bold.ttf, 20"
        set xdata time
        set timefmt  "%Y-%m-%d"
        set format x  "%Y-%m-%d"
        set xtics rotate
        set yrange [0:] noreverse
        set xlabel 'Time: daily'
        set ylabel '10k PageView'
        set terminal png giant size 1000,500 
        set output "/tmp/tomcatHistory.png"
        plot "$N" using 1:2 title '$serverList[0]' with lines linecolor rgb "red" linewidth 1.5,\\
             "$N" using 1:3 title '$serverList[1]' with lines linecolor rgb "blue" linewidth 1.5,\\
             "$N" using 1:4 title '$serverList[2]' with lines linecolor rgb "orange" linewidth 1.5,\\
             "$N" using 1:5 title '$serverList[3]' with lines linecolor rgb "brown" linewidth 1.5,\\
             "$N" using 1:6 title 'average' with lines linecolor rgb "green" linewidth 2.5,\\
];
close $P;


`cp $N "/home/moqingqiang/tmp/$date-his.txt"` ;
`cp "/tmp/tomcatHistory.png" "/home/moqingqiang/tmp/$date-his.png"` ;

#-------------------------------------------------------------------------------
# mail -> mutt -> msmtp 
#-------------------------------------------------------------------------------
#my $systemCommand=q#mutt -e "my_hdr Content-Type: text/html" -s "# . qq#$date# . q# TomcatHistoryPV" -a "/tmp/tomcatHistory.png" moqingqiang@richinfo.cn < # . qq#$N# ;
#`$systemCommand`;
