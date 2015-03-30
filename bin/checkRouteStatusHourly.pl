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

my ($dirname, $filename, $tmpfile) = ($1,$3,"/tmp/$3-$$.tmp") if $0 =~ m/^(.*)(\\|\/)(.*)\.([0-9a-z]*)/;

open my $fho , "> $tmpfile" || die $!;
chomp(my $timestamp = `date -d -1hour +"%F %T"`);
$timestamp =~ s/:.*$//;

foreach my $file ( @files ) {
    open my $fh , "< $file" || die $!;
    while ( <$fh> ) {
        #print $fho $_ if $_ =~ /^$timestamp/ ;
        if ( /^$timestamp/ ) {
            chomp;
            printf $fho "%s router error. at $file\n", $_;
        }
    }
    close $fh; 
}
close $fho ; 

if ( -s "$tmpfile" ) {
    my $systemCommand=q#echo -e "Subject: routeTableErrs\n\n" | cat - # .  "$tmpfile" . q# | /usr/local/bin/msmtp 13725269365@139.com# ;
    `$systemCommand`;
}
unlink $tmpfile ;
