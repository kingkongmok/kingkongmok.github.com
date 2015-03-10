#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: tomcatSizeAnalyze.pl
#
#        USAGE: ./tomcatSizeAnalyze.pl  
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
open my $fh_log1 , "/home/logs/1_mmlogs/crontabLog/tomcat_accesslog_size.log" ;
open my $fh_log2 , "/home/logs/4_mmlogs/crontabLog/tomcat_accesslog_size.log" ;
open my $fh_log3 , "/home/logs/3_mmlogs/crontabLog/tomcat_accesslog_size.log" ;
open my $fh_log4 , "/home/logs/5_mmlogs/crontabLog/tomcat_accesslog_size.log" ;
#
# output for png and txt header
my @serverList = qw( 42.1 42.2 42.3 42.5 );
#
#
#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------
# yesterday output
my $date = `date +%F -d -1day`;
#
# 24 hour, don't edit
my @date_str = (1..24);


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
print $T "#Time\t", join"\t",@serverList, "\n" ;
for my $k (0 .. 23) {
        print $T $date_str[$k], "\t", $size1->[$k], "\t", $size2->[$k], "\t", $size3->[$k], "\t", $size4->[$k], "\n";
}
close $T;
open my $P, "|-", "gnuplot" or die;
printflush $P qq[
        set title "Tomcat AccessLog Size Hourly Report"
        set xdata time
        set timefmt "%H"
        set format x "%H"
        set xtics rotate
        set yrange [0:] noreverse
        set xlabel 'Time: Hourly'
        set ylabel 'LogSize in MB'
        set terminal png giant size 1000,500 
        set output "/tmp/tomcatLogSize.png"
        plot "$N" using 1:2 title '$serverList[0]' with lines linecolor rgb "red" linewidth 1.5,\\
             "$N" using 1:3 title '$serverList[1]' with lines linecolor rgb "blue" linewidth 1.5,\\
             "$N" using 1:4 title '$serverList[2]' with lines linecolor rgb "orange" linewidth 1.5,\\
             "$N" using 1:5 title '$serverList[3]' with lines linecolor rgb "green" linewidth 1.5,\\
];
close $P;


#-------------------------------------------------------------------------------
# mail -> mutt -> msmtp 
#-------------------------------------------------------------------------------
my $systemCommand=q#mutt -e "my_hdr Content-Type: text/html" -s "# . qq#$date# . q# TomcatLogSize" -a "/tmp/tomcatLogSize.png" moqingqiang@richinfo.cn < # . qq#$N# ;
`$systemCommand`;
rename $N, "/home/moqingqiang/tmp/$date.log";
rename "/tmp/tomcatLogSize.png", "/home/moqingqiang/tmp/$date.png";
