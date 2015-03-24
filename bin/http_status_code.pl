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
#use warnings FATAL => qw(uninitialized);
use Storable qw(store retrieve);

chomp(my $lastHour = `date +%F.%H -d -1hour`);
chomp(my $today = `date +%F -d -1hour`);

#-------------------------------------------------------------------------------
#  methods to monitor
#-------------------------------------------------------------------------------
my @methodArray = qw / 
                    mmsdk:postactlog
                    mmsdk:posteventlog
                    mmsdk:postsyslog
                /;

#-------------------------------------------------------------------------------
#  log location
#-------------------------------------------------------------------------------
my @logArray = glob "/mmsdk/tomcat_77*/access.$lastHour.log" ;
my $outputfilename = "/mmsdk/crontabLog/http_status_code.log" ;
my $outputPVline_file = "/mmsdk/crontabLog/tomcat_accesslog_line.log" ;
my $outputRespTime_file = "/mmsdk/crontabLog/http_resp_time.log" ;
my $outputMethodCount_file = "/mmsdk/crontabLog/http_method_count.log" ;
my $hashFileLocation = "/mmsdk/crontabLog/http_status_code.hash.log";
my $hashRespTimeFileLocation = "/mmsdk/crontabLog/http_resp_time.hash.log";
my $hashMethodCountFileLocation = "/mmsdk/crontabLog/http_method_count.hash.log";
#
#my @logArray = glob "/tmp/test/*/*log" ;
#my $outputfilename = "/tmp/http_status_code.log" ;
#my $outputPVline_file = "/tmp/tomcat_accesslog_line.log" ;
#my $outputRespTime_file = "/tmp/http_resp_time.log" ;
#my $outputMethodCount_file = "/tmp/http_method_count.log" ;
#my $hashFileLocation = "/tmp/http_status_code.hash.log";
#my $hashRespTimeFileLocation = "/tmp/http_resp_time.hash.log";
#my $hashMethodCountFileLocation = "/tmp/http_method_count.hash.log";

my $httpstatusref ;
my $httpresp ;
my $httpMethodCount ;
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
if ( -s $hashMethodCountFileLocation ) {
    $httpMethodCount = retrieve("$hashMethodCountFileLocation");
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
            my $tmptime = $1;
            $httpMethodCount->{$tmptime}{other}++;
            if ( /(?<=func=)(\S+?)(?=\&)/ ) {
                foreach my $method ( @methodArray ) {
                    if ( $1 eq $method ) {
                        $httpMethodCount->{$tmptime}{$method}++;
                        $httpMethodCount->{$tmptime}{other}--;
                        last;
                    }
                }
            }
        }
    }
}
open my $fho, "> $outputfilename" || die $!;
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

open my $fho1, ">> $outputPVline_file" || die $!;
foreach my $filename ( @logArray ) {
    printf $fho1 "%i %s\n", $pvCount{$filename}, $filename ;
}
close $fho1;

open my $fho2, "> $outputRespTime_file" || die $!;
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

open my $fho3, "> $outputMethodCount_file" || die $!;
my ($methodTotalTime, $methodTotalCount);
print $fho3 "#time\t", join"\t",@methodArray, "\tother\t$today\n" ;
foreach my $time ( sort keys %{$httpMethodCount} ) {
        printf $fho3 "%s\t", $time ;
        foreach my $method ( @methodArray ) {
            if ( $httpMethodCount->{$time}{$method} ) {
                printf  $fho3 "%s\t", $httpMethodCount->{$time}{$method} ;
            }
            else {
                printf $fho3 "%s\t", 0 ;
            }
        }
        printf $fho3 "%s\t", $httpMethodCount->{$time}{other} ;
        print $fho3 "\n";
}
close $fho3;

#-------------------------------------------------------------------------------
#  backup hash
#-------------------------------------------------------------------------------
store($httpstatusref, "$hashFileLocation") or die "Can't store %hash in $hashFileLocation!\n";
store($httpresp, "$hashRespTimeFileLocation") or die "Can't store %hash in $hashRespTimeFileLocation!\n";
store($httpMethodCount, "$hashMethodCountFileLocation") or die "Can't store %hash in $hashMethodCountFileLocation!\n";
