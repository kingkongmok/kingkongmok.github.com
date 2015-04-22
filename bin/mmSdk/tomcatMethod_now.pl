#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: tomcatMethod.pl
#
#        USAGE: ./tomcatMethod.pl  
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
open my $fh_log1 , "/home/logs/1_mmlogs/crontabLog/http_method_count.log"  || die $!;
open my $fh_log2 , "/home/logs/4_mmlogs/crontabLog/http_method_count.log"  || die $!;
open my $fh_log3 , "/home/logs/3_mmlogs/crontabLog/http_method_count.log"  || die $!;
open my $fh_log4 , "/home/logs/5_mmlogs/crontabLog/http_method_count.log"  || die $!;
#
# output for png and txt header
my @methodArray = qw / 
                    mmsdk:postactlog
                    mmsdk:posteventlog
                    mmsdk:postsyslog
                    other
                /;
#
#
#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------
#
# last hour, don't edit
#my @date_str = push @date_str, 
my (undef, undef, $h, undef, undef, undef) = localtime(time()-60*60);
my @hourArray = map{sprintf"%02i",$_}0..$h ;
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
    my ( $line1, $line2, $line3, $line4 );
    foreach my $dateInterator ( 0..$#date_str ) {
        $line1->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[0]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[0]}:0;
        $line2->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[1]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[1]}:0;
        $line3->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[2]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[2]}:0;
        $line4->[$dateInterator] = $sumResultHash->{$date_str[$dateInterator]}{$methodArray[3]}?$sumResultHash->{$date_str[$dateInterator]}{$methodArray[3]}:0;
    }
    return ($line1, $line2, $line3, $line4) ;
} ## --- end sub sumResults


my %sumResultHash;
my ( $line1, $line2, $line3, $line4 ) = sumResults(\%sumResultHash, $fh_log1, $fh_log2, $fh_log3, $fh_log4 );



#-------------------------------------------------------------------------------
# use gnuplot command by shell, not PM
#-------------------------------------------------------------------------------
my($T,$N) = tempfile("/tmp/tomcatMethod-$$-XXXX", "UNLINK", 1);
print $T "#Time\t", join"\t",@methodArray, "\n" ;
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
open my $P, "|-", "/opt/mmSdk/local/gnuplot-5.0.0/bin/gnuplot" or die;
#open my $P, "|-", "gnuplot" or die;
printflush $P qq[
        set key top left title "TotalMaxValue=$maxValue(PV) at $maxTime"
        set title "Today Methods visited" font "/usr/share/fonts/dejavu-lgc/DejaVuLGCSansMono-Bold.ttf, 20"
        set xdata time
        set timefmt "%H:%M"
        set format x "%H:%M"
        set xtics rotate
        set yrange [0:] noreverse
        set xlabel 'Time: every minute'
        set ylabel 'Http Method Visited'
        set terminal png giant size 1000,500 
        set output "/tmp/tomcatMethod_now.png"
        plot "$N" using 1:2 title '$methodArray[0]' with lines linecolor rgb "#008B8B" linewidth 1.5,\\
             "$N" using 1:3 title '$methodArray[1]' with lines linecolor rgb "#B8860B" linewidth 1.5,\\
             "$N" using 1:4 title '$methodArray[2]' with lines linecolor rgb "#006400" linewidth 1.5,\\
             "$N" using 1:5 title '$methodArray[3]' with lines linecolor rgb "#8B008B" linewidth 1.5,\\
];
close $P;
