#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: http_status_code.pl
#
#        USAGE: ./http_status_code.pl  
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
#      CREATED: 03/13/2015 11:42:38 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Storable qw(store retrieve);

chomp(my $lastHour = `date +%F.%H -d -1hour`);
chomp(my $today = `date +%F -d -1hour`);

#-------------------------------------------------------------------------------
#  log location
#-------------------------------------------------------------------------------
my @logArray = glob "/mmsdk/tomcat_77*/access.$lastHour.log" ;
my $outputfilename = "/mmsdk/crontabLog/http_status_code.log" ;
my $outputPVline_file = "/mmsdk/crontabLog/tomcat_accesslog_line.log" ;
my $outputRespTime_file = "/mmsdk/crontabLog/http_resp_time.log" ;
my $hashFileLocation = "/mmsdk/crontabLog/http_status_code.hash.log";
my $hashRespTimeFileLocation = "/mmsdk/crontabLog/http_resp_time.hash.log";


my $httpstatusref ;
my $httpresp ;
my %pvCount;
#-------------------------------------------------------------------------------
#  restore hash
#-------------------------------------------------------------------------------
if ( -s $hashFileLocation ) {
    $httpstatusref = retrieve("$hashFileLocation");
}
if ( -s $hashRespTimeFileLocation ) {
    $httpresp = retrieve("$hashRespTimeFileLocation");
}
foreach my $filename ( @logArray ) {
    open my $fh , $filename || die $!;
    while ( <$fh> ) {
        chomp ; 
            $pvCount{$filename}++;
        if ( /^[^:]+:(\d{2}:\d{2}):\d{2} \+0800\] (\d)\d{2} (\d+\.\d{3}) / ) {
            $httpstatusref->{$1}{$2}++;
            $httpresp->{time}{$1}+=$3;
            $httpresp->{count}{$1}++;
        }
    }
}
open my $fho, "> $outputfilename" ;
print $fho "#time\t1xx\t2xx\t3xx\t4xx\t5xx\t$today\n" ;
foreach my $time ( sort keys %{$httpstatusref} ) {
        printf $fho "%s\t", $time ;
        foreach my $httpCode ( 1..5 ) {
            if ( $httpstatusref->{$time}{$httpCode} ) {
                printf  $fho "%s\t", $httpstatusref->{$time}{$httpCode} ;
            }
            else {
                printf $fho "%s\t", 0 ;
            }
        }
        print $fho "\n";
}
close $fho;

open my $fho1, ">> $outputPVline_file" ;
foreach my $filename ( @logArray ) {
    printf $fho1 "%i %s\n", $pvCount{$filename}, $filename ;
}
close $fho1;

open my $fho2, "> $outputRespTime_file" ;
my ($totaltime, $totalcount);
print $fho2 "#time\taverageResptime\t$today\n" ;
foreach my $time ( sort keys %{$httpresp->{time}} ) {
        printf $fho2 "%s %0.4f", $time,  $httpresp->{time}{$time} / $httpresp->{count}{$time};
        $totaltime+=$httpresp->{time}{$time};
        $totalcount+=$httpresp->{count}{$time};
        print $fho2 "\n";
}
printf $fho2 "#total Average %0.4f\n", $totaltime / $totalcount ;
close $fho2;

#-------------------------------------------------------------------------------
#  backup hash
#-------------------------------------------------------------------------------
store($httpstatusref, "$hashFileLocation") or die "Can't store %hash in $hashFileLocation!\n";
store($httpresp, "$hashRespTimeFileLocation") or die "Can't store %hash in $hashRespTimeFileLocation!\n";
