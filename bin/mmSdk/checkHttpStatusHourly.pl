#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: checkHttpStatusHourly.pl
#
#        USAGE: ./checkHttpStatusHourly.pl
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
use POSIX qw/strftime/;

my @files = glob("/home/logs/*/crontabLog/http_error.log");
# my @files = glob("/tmp/http_error.log*");

my ($dirname, $filename, $tmpfile) = ($1,$3,"/tmp/$3-$$.tmp") if $0 =~ m/^(.*)(\\|\/)(.*)\.([0-9a-z]*)/;


my $regex = strftime "%F %H", localtime( time() - 60*60 );
my $last_hour = strftime "%H", localtime( time() - 60*60 );
my $now_hour = strftime "%H", localtime();

my %httperror;
foreach my $file ( @files ) {
    open my $fh , "< $file" || die $!;
    while ( <$fh> ) {
        if ( $_ =~ $regex ) {
            my @F = split ;
            $httperror{$F[2]}++ ;
        }
    }
    close $fh; 
}


open my $fho , "> $tmpfile";
printf $fho "there's some http errors occored during %s:00~%s:00:\n", $last_hour, $now_hour;
while ( my( $server, $errortimes ) = each %httperror ) {
    printf $fho "%s %s times\n", $server, $errortimes;
}
close $fho ; 

if ( -s "$tmpfile" ) {
    my $systemCommand=q#echo -e "Subject: httpErrs\n\n" | cat - # .  "$tmpfile" . q# | /usr/local/bin/msmtp 13725269365@139.com# ;
    `$systemCommand`;
}
unlink $tmpfile ;
