#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: tomcatMethodSmall.pl
#
#        USAGE: ./tomcatMethodSmall.pl
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
open my $fh_log1 , "zcat /home/logs/1_mmlogs/crontabLog/http_method_count.log.1.gz | "  || die $!;
open my $fh_log2 , "zcat /home/logs/4_mmlogs/crontabLog/http_method_count.log.1.gz | "  || die $!;
open my $fh_log3 , "zcat /home/logs/3_mmlogs/crontabLog/http_method_count.log.1.gz | "  || die $!;
open my $fh_log4 , "zcat /home/logs/5_mmlogs/crontabLog/http_method_count.log.1.gz | "  || die $!;
#
# output for png and txt header
my @methodArray = qw/ 
                    mmsdk:postactlog
                    mmsdk:posteventlog
                    mmsdk:postsyslog
                    mmsdk:posterrlog
                    mmsdk:getappparameter
                    u.gif
                    udata.js
                    gamesdk:postactlog
                    mmsdk:specposteventlog
                    gamesdk:postgamelog
                    gamesdk:postsyslog
                    other
                /;
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
#         NAME: sumResults
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub sumResults {
    my $sumResultHash = shift;
    foreach my $fh ( @_ ) {
        while ( <$fh> ) {
            if ( /^\d/ ) {
                my @F = split ;
                foreach my $methodInterator ( 0..$#methodArray ) {
                    $sumResultHash->{$F[0]}{$methodArray[$methodInterator]}+=$F[$methodInterator + 1];
                }
            }
        }
    }
    my ( $line1, $line2, $line3, $line4, $line5, $line6, $line7, $line8, $line9, $line10, $line11, $line12 );
    foreach my $dateInterator ( 0..$#date_str ) {
        $line1->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[0]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[0]}:0;
        $line2->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[1]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[1]}:0;
        $line3->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[2]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[2]}:0;
        $line4->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[3]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[3]}:0;
        $line5->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[4]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[4]}:0;
        $line6->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[5]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[5]}:0;
        $line7->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[6]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[6]}:0;
        $line8->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[7]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[7]}:0;
        $line9->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[8]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[8]}:0;
        $line10->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[9]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[9]}:0;
        $line11->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[10]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[10]}:0;
        $line12->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[11]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[11]}:0;
    }
    return ($line1, $line2, $line3, $line4, $line5, $line6, $line7, $line8, $line9, $line10, $line11, $line12) ;
} ## --- end sub sumResults


my %sumResultHash;
my ( $line1, $line2, $line3, $line4, $line5, $line6, $line7, $line8, $line9, $line10, $line11, $line12 ) 
    = sumResults(\%sumResultHash, $fh_log1, $fh_log2, $fh_log3, $fh_log4 );



#-------------------------------------------------------------------------------
# use gnuplot command by shell, not PM
#-------------------------------------------------------------------------------
my($T,$N) = tempfile("/tmp/tomcatMethod-$$-XXXX", "UNLINK", 1);
print $T "#Time\t", join"\t",@methodArray, "\n" ;
my $maxValue = 0;
my $maxTime = 0;
for my $k (0..(~~@date_str-1)) {
    if ( 
        defined $line1->[$k] && defined $line2->[$k] && $line3->[$k] && defined $line4->[$k] &&
        defined $line5->[$k] && defined $line6->[$k] && $line7->[$k] && defined $line8->[$k] &&
        defined $line9->[$k] && defined $line10->[$k] && $line11->[$k] && defined $line12->[$k] 
        ) {
        if ( $maxValue < (
                $line1->[$k]+$line2->[$k]+$line3->[$k]+$line4->[$k]+
                $line5->[$k]+$line6->[$k]+$line7->[$k]+$line8->[$k]+
                $line9->[$k]+$line10->[$k]+$line11->[$k]+$line12->[$k]
            ) ) {
            $maxValue = (
                            $line1->[$k]+$line2->[$k]+$line3->[$k]+$line4->[$k]+
                            $line5->[$k]+$line6->[$k]+$line7->[$k]+$line8->[$k]+
                            $line9->[$k]+$line10->[$k]+$line11->[$k]+$line12->[$k]
                        ) ;
            $maxTime = $date_str[$k] ;
        }
        print $T $date_str[$k], "\t", 
            $line1->[$k], "\t", $line2->[$k], "\t", $line3->[$k], "\t", $line4->[$k], "\t",
            $line5->[$k], "\t", $line6->[$k], "\t", $line7->[$k], "\t", $line8->[$k], "\t",
            $line9->[$k], "\t", $line10->[$k], "\t", $line11->[$k], "\t", $line12->[$k], "\t",
            int(($line1->[$k] + $line2->[$k] + $line3->[$k] + $line4->[$k] + $line5->[$k]
                    + $line6->[$k] + $line7->[$k] + $line8->[$k] + $line9->[$k] + $line10->[$k]
                    + $line11->[$k] + $line12->[$k] )/4 ), "\n",
    }
}
close $T;
open my $P, "|-", "/opt/mmSdk/local/gnuplot-5.0.0/bin/gnuplot" or die;
#open my $P, "|-", "gnuplot" or die;
printflush $P qq[
        set key top left title "TotalMaxValue=$maxValue(PV) at $maxTime"
        set title "All Tomcat $yesterday Methods visited SmallVie" font "/usr/share/fonts/dejavu-lgc/DejaVuLGCSansMono-Bold.ttf, 20"
        set xdata time
        set timefmt "%H:%M"
        set format x "%H:%M"
        set grid
        set xtics rotate
        set yrange [0:] noreverse
        set xlabel 'Time: every minute'
        set ylabel 'Http Method Visited'
        set terminal png giant size 1000,500 
        set output "/tmp/tomcatMethodSmall.png"
        plot "$N" using 1:6 title '$methodArray[4]' with lines linecolor rgb "#DC143C" ,\\
             "$N" using 1:7 title '$methodArray[5]' with lines linecolor rgb "#00FF00" ,\\
             "$N" using 1:8 title '$methodArray[6]' with lines linecolor rgb "#00FFFF" ,\\
             "$N" using 1:9 title '$methodArray[7]' with lines linecolor rgb "#8B0000" ,\\
             "$N" using 1:10 title '$methodArray[8]' with lines linecolor rgb "#E9967A",\\
             "$N" using 1:11 title '$methodArray[9]' with lines linecolor rgb "#8FBC8F",\\
             "$N" using 1:12 title '$methodArray[10]' with lines linecolor rgb "#483D8B",\\
             "$N" using 1:13 title '$methodArray[11]' with lines linecolor rgb "#2F4F4F",\\
];
close $P;


`cp $N "/opt/mmSdk/tmp/$yesterday-Method.txt"` ;
`cp "/tmp/tomcatMethod.png" "/opt/mmSdk/tmp/$yesterday-Method.png"` ;
