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


# last hour, don't edit
#my @date_str = push @date_str, 
my (undef, undef, $h, undef, undef, undef) = localtime(time()-60*60);
my @hourArray = map{sprintf"%02i",$_}0..$h ;
my @minuteArray = map{sprintf"%02i", $_}0..59 ;
my @date_str ;
my $lastHourNumb = sprintf "%02d",$h ;


foreach my $hour ( @hourArray ) {
    foreach my $minute ( @minuteArray ) {
        push @date_str ,"$hour:$minute" ;
    }
}

#-------------------------------------------------------------------------------
#  methods to monitor
#-------------------------------------------------------------------------------
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
# my @logArray = glob "/home/kk/Documents/logs/*.log" ;
# my $outputfilename = "/tmp/http_status_code.log" ;
# my $outputPVline_file = "/tmp/tomcat_accesslog_line.log" ;
# my $outputRespTime_file = "/tmp/http_resp_time.log" ;
# my $outputMethodCount_file = "/tmp/http_method_count.log" ;
# my $hashFileLocation = "/tmp/http_status_code.hash.log";
# my $hashRespTimeFileLocation = "/tmp/http_resp_time.hash.log";
# my $hashMethodCountFileLocation = "/tmp/http_method_count.hash.log";

my $httpstatusref ;
my $httpresp ;
my $httpMethodCount ;
my %pvCount;


# #-------------------------------------------------------------------------------
# #  backup hash file and logfile before actioin
# #-------------------------------------------------------------------------------
# sub backupfile {
#     my $lastHourNumb = shift ;
#     my @files = @_ ;
#     foreach my $file ( @files ) {
#         my $backupfilename = $file . "_" . $lastHourNumb;
#         use File::Copy qw(copy);
#         copy $file, $backupfilename;
#     }
# }
# backupfile( $lastHourNumb , $outputfilename, $outputPVline_file, $outputRespTime_file, $outputMethodCount_file, $hashFileLocation, $hashRespTimeFileLocation, $hashMethodCountFileLocation );


#-------------------------------------------------------------------------------
#  restore hash from file, which Storable->retrieve
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


#-------------------------------------------------------------------------------
#  analyze log files, insert hash.
#-------------------------------------------------------------------------------
foreach my $filename ( @logArray ) {
    open my $fh , $filename || die $!;
    while ( <$fh> ) {
        chomp ; 
            $pvCount{$filename}++;
#-------------------------------------------------------------------------------
#  count specify hour in logfile. Wihtout counting the last hour 00 minutes.
#-------------------------------------------------------------------------------
        # if ( /^[^:]+:(\d{2}:\d{2}):\d{2} \+0800\] (\d)\d{2} (\d+\.\d{3}) / ) {
        if ( /^[^:]+:($lastHourNumb:\d{2}):\d{2} \+0800\] (\d)\d{2} (\d+\.\d{3}) / ) {
            $httpstatusref->{$1}{$2}++;
            $httpresp->{time}{$1}+=$3;
            $httpresp->{count}{$1}++;
            my $tmptime = $1;
            if ( /(?<=func=)(\S+?)(?=\&)/ ) {
                $httpMethodCount->{$tmptime}{$1}++;
            }elsif ( /(udata\.js|u\.gif)/ ) {
                $httpMethodCount->{$tmptime}{$1}++;
            } else {
                $httpMethodCount->{$tmptime}{"unknown"}++;
            }
        }
    }
}


#-------------------------------------------------------------------------------
#  output http_status_code.log
#-------------------------------------------------------------------------------
open my $fho, "> $outputfilename" || die $!;
print $fho "#time\t1xx\t2xx\t3xx\t4xx\t5xx\t$today\n" ;
foreach my $time ( @date_str ) {
    printf $fho "%s\t", $time ;
    foreach my $httpCode ( 1..5 ) {
        my $currentColumn = $httpstatusref->{$time}{$httpCode} || 0 ;
        printf  $fho "%s\t", $currentColumn;
    }
    print $fho "\n";
}
close $fho;


#-------------------------------------------------------------------------------
#  output tomcat_accesslog_line.log
#-------------------------------------------------------------------------------
open my $fho1, ">> $outputPVline_file" || die $!;
foreach my $filename ( @logArray ) {
    printf $fho1 "%i %s\n", $pvCount{$filename}, $filename ;
}
close $fho1;


#-------------------------------------------------------------------------------
#  output http_resp_time.log
#-------------------------------------------------------------------------------
open my $fho2, "> $outputRespTime_file" || die $!;
my $totalcount = 0 ;
my $totaltime = 0 ;
print $fho2 "#time\taverageResptime\t$today\n" ;
foreach my $time ( @date_str ) {
    my $currentColumn = $httpresp->{count}{$time}
        ?
            $httpresp->{time}{$time} / $httpresp->{count}{$time}
        :
            0 ;
    printf $fho2 "%s %0.4f", $time, $currentColumn;
    if ( $httpresp->{time}{$time} ) {
        $totaltime+=$httpresp->{time}{$time};
    }
    if ( $httpresp->{time}{$time} ) {
        $totalcount+=$httpresp->{count}{$time};
    }
    print $fho2 "\n";
}
my $totalAverage = $totalcount ? $totaltime / $totalcount : 0;    
printf $fho2 "#total Average %0.4f\n", $totalAverage;
close $fho2;


#-------------------------------------------------------------------------------
#  output http_method_count.log
#-------------------------------------------------------------------------------
open my $fho3, "> $outputMethodCount_file" || die $!;
my ($methodTotalTime, $methodTotalCount);
print $fho3 "#time\t", join"\t",@methodArray, "\tother\t$today\n" ;
foreach my $time ( @date_str ) {
    printf $fho3 "%s\t", $time ;
    my $sum = 0;
    $sum += $_ for values %{$httpMethodCount->{$time}};
    foreach my $method ( @methodArray ) {
        if ( $sum == 0 ) {
            printf $fho3 "%s\t", 0 ;
        } else {
            if ( $httpMethodCount->{$time}{$method} ) {
                printf  $fho3 "%s\t", $httpMethodCount->{$time}{$method} ;
                $sum -= $httpMethodCount->{$time}{$method} ;
            }
            else {
                printf $fho3 "%s\t", 0;
            }
        }
    }
    printf $fho3 "%s\t", $sum ;
    print $fho3 "\n";
}
close $fho3;


#-------------------------------------------------------------------------------
#  backup hash to file, using Storable->store.
#-------------------------------------------------------------------------------
store($httpstatusref, "$hashFileLocation") or die "Can't store %hash in $hashFileLocation!\n";
store($httpresp, "$hashRespTimeFileLocation") or die "Can't store %hash in $hashRespTimeFileLocation!\n";
store($httpMethodCount, "$hashMethodCountFileLocation") or die "Can't store %hash in $hashMethodCountFileLocation!\n";


# #-------------------------------------------------------------------------------
# #  zip the tomcat accesslog files.
# #-------------------------------------------------------------------------------
# sub zipLogFile {
#     my @logArray = @_ ;
#     use IO::Compress::Gzip qw(gzip $GzipError) ;
#     foreach my $filename ( @logArray ) {
#         gzip $filename => "$filename.gz" || die "gzip failed: $GzipError\n" ;
#         unlink $filename ;
#     }
# }
# # zipLogFile( @logArray );
