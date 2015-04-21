#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: checkRouteStatusHourly.pl
#
#        USAGE: ./checkRouteStatusHourly.pl
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
#      CREATED: 02/10/2015 09:39:23 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my @files = glob("/home/logs/*_mmlogs/crontabLog/checkRouter.log");
#my @files = glob("/tmp/test/*/checkRouter.log");

my %ip_file = ( "/home/logs/1_mmlogs/crontabLog/checkRouter.log" => "192.168.42.1",
                "/home/logs/4_mmlogs/crontabLog/checkRouter.log" => "192.168.42.2",
                "/home/logs/3_mmlogs/crontabLog/checkRouter.log" => "192.168.42.3",
                "/home/logs/5_mmlogs/crontabLog/checkRouter.log" => "192.168.42.4",
              ); 

my ($dirname, $filename, $tmpfile) = ($1,$3,"/tmp/$3-$$.tmp") if $0 =~ m/^(.*)(\\|\/)(.*)\.([0-9a-z]*)/;

open my $fho , "> $tmpfile" || die $!;
# chomp(my $timestamp = `date -d -1hour +"%F %T"`);
# $timestamp =~ s/:.*$//;

my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
chomp (my $timestamp = sprintf "%d-%02d-%02d %02d\n", $year+1900, $mon+1, $mday, $hour-1);
my $mailSubj ;

foreach my $file ( @files ) {
    open my $fh , "< $file" || die $!;
    while ( <$fh> ) {
        if ( /^tracing route start at ($timestamp.*)/ ) {
            chomp;
            $mailSubj="route error at $ip_file{$file} $1";
            printf $fho $mailSubj , "\n";
        }
    }
    close $fh; 
}
close $fho ; 

if ( -s "$tmpfile" ) {
    my $systemCommand=q#echo -e "Subject: routeTableErrs\n\n" | cat - # .  "$tmpfile" . q# | /usr/local/bin/msmtp 13725269365@139.com# ;
    `$systemCommand`;

    $systemCommand=qq{echo "<pre style=background:#A9F5E1>" >> /tmp/pv_mail_now.txt &&  cat /home/logs/*_mmlogs/crontabLog/checkRouter.log >> /tmp/pv_mail_now.txt && echo "</pre>" >> /tmp/pv_mail_now.txt && /opt/mmSdk/bin/pvAnalyze_now.sh $mailSubj};
    `$systemCommand`;
}

unlink $tmpfile ;
