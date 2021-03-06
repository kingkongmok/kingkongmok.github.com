#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: logSizeAnalyze_manual.pl
#
#        USAGE: logSizeAnalyze_manual.pl tomcat_accesslog_size.log.1.gz
#
#  DESCRIPTION: analyze tomcat's logSize, output specified logFile's png analyze. 
#
#      OPTIONS: ---
# REQUIREMENTS: /tmp/test fold.
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
use POSIX qw(strftime);

if ($#ARGV == -1)
{
        print "Error! No input arguments entered!\n";
        print "please insert logfile's filename e.g.:\n\n";
        print "\t\"logSizeAnalyze_manual.pl tomcat_accesslog_size.log.1.gz\"\n";
        exit(-1);
}

# tomcat yesterday log location
#open my $fh_log1 , "/home/logs/1_mmlogs/crontabLog/tomcat_accesslog_size.log" ;
#open my $fh_log2 , "/home/logs/4_mmlogs/crontabLog/tomcat_accesslog_size.log" ;
#open my $fh_log3 , "/home/logs/3_mmlogs/crontabLog/tomcat_accesslog_size.log" ;
#open my $fh_log4 , "/home/logs/5_mmlogs/crontabLog/tomcat_accesslog_size.log" ;
my $logfileName = $ARGV[0];
open my $fh_log1 , '-|', 'gzip', '-dc', "/home/logs/1_mmlogs/crontabLog/$logfileName" || die $!;
open my $fh_log2 , '-|', 'gzip', '-dc', "/home/logs/4_mmlogs/crontabLog/$logfileName" || die $!;
open my $fh_log3 , '-|', 'gzip', '-dc', "/home/logs/3_mmlogs/crontabLog/$logfileName" || die $!;
open my $fh_log4 , '-|', 'gzip', '-dc', "/home/logs/5_mmlogs/crontabLog/$logfileName" || die $!;
#
# output for png and txt header
my @serverList = qw( 42.1 42.2 42.3 42.5 );
#
#
#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

unless (-d "/tmp/test") {
    mkdir "/tmp/test";
}

my $epoch_timestamp = +(stat("/home/logs/1_mmlogs/crontabLog/$logfileName"))[9];
# yesterday 
$epoch_timestamp -=  24 * 60 * 60; 
my $date       = strftime("%F",localtime($epoch_timestamp) );

#
# 24 hour, don't edit
my @date_str = (0..23);


#===  FUNCTION  ================================================================
#         NAME: getTomcatSizeArray
#      PURPOSE: 
#   PARAMETERS: log filehandle
#      RETURNS: tomcat 77{11,22,33,44} filesize (MB) array by hourly
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getTomcatSizeArray {
    my	( $fh )	= @_;
    my %H;
    while ( <$fh> ) {
        if ( /(\d{2})\.log$/ ) {
            my @F = split ;
            # show file in MB, not byte
            $H{$1}+=int($F[0]/1048576);
        }
    }
    my @dateOut = map{ $H{$_} } sort{$a<=>$b} keys %H;
    return \@dateOut;
} ## --- end sub getTomcatSizeArray

my $size1 = &getTomcatSizeArray($fh_log1);
my $size2 = &getTomcatSizeArray($fh_log2);
my $size3 = &getTomcatSizeArray($fh_log3);
my $size4 = &getTomcatSizeArray($fh_log4);


#-------------------------------------------------------------------------------
# use gnuplot command by shell, not PM
#-------------------------------------------------------------------------------
my($T,$N) = tempfile("/tmp/tomcatSizeAnalyze-$$-XXXX", "UNLINK", 1);
print $T "#Time\t", join"\t",@serverList, "\t", "average", "\n" ;
my $maxValue = 0;
my $maxTime = 0;
my $maxTimeNext = 0;
for my $k (0 .. 23) {
    if ( $maxValue < ($size1->[$k]+$size2->[$k]+$size3->[$k]+$size4->[$k])/4 ) {
        $maxValue = ($size1->[$k]+$size2->[$k]+$size3->[$k]+$size4->[$k])/4 ;
        $maxTime = $k ;
        $maxTimeNext = $k + 1;
    }
    print $T $date_str[$k], "\t", 
        $size1->[$k], "\t", $size2->[$k], "\t", 
        $size3->[$k], "\t", $size4->[$k], "\t",
        int(($size1->[$k] + $size2->[$k] + $size3->[$k] + $size4->[$k])/4 ), "\n",
}
my $TotalValue = $maxValue * 4 ; 
close $T;
open my $P, "|-", "/opt/mmSdk/local/gnuplot-5.0.0/bin/gnuplot" or die;
printflush $P qq[
        set key top left title "MaxAverage=$maxValue(MB logSize) with Total=$TotalValue(MB logSize) at $maxTime:00 ~ $maxTimeNext:00"
        set title "All Tomcat $date Tomcat AccessLog Size Hourly" font "/usr/share/fonts/dejavu-lgc/DejaVuLGCSansMono-Bold.ttf, 20"
        set xdata time
        set timefmt "%H"
        set format x "%H"
        set grid
        set xtics rotate
        set yrange [0:] noreverse
        set xlabel 'Time: Hourly'
        set ylabel 'LogSize in MB'
        set terminal png giant size 1000,500 
        set output "/tmp/test/$date.png"
        plot "$N" using 1:2 title '$serverList[0]' with lines linecolor rgb "red" linewidth 1.5,\\
             "$N" using 1:3 title '$serverList[1]' with lines linecolor rgb "blue" linewidth 1.5,\\
             "$N" using 1:4 title '$serverList[2]' with lines linecolor rgb "orange" linewidth 1.5,\\
             "$N" using 1:5 title '$serverList[3]' with lines linecolor rgb "brown" linewidth 1.5,\\
             "$N" using 1:6 title 'average' with lines linecolor rgb "green" linewidth 2.5,\\
];
close $P;

print "output file: /tmp/test/$date.png\n";
