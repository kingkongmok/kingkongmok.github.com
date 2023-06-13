#!/usr/bin/env perl 

use strict;
use warnings;

#my $log="/tmp/caldavSync.log";
my $log="/home/logs/cardDav/caldavSync.log";


$log = $ARGV[0] if $ARGV[0];
my $fh ;
if ( $log =~ /gz$/ ) {
    open $fh, "zcat $log|" || die $!;
}
else {
    open $fh,$log || die $!;
}

my @methods = ( "getUserPartID", "calendarQuery", "info", "checkPwd", "checkUserSms", "calendarMultiget", "propertyupdate" );

my %H;
my @errors;
while ( <$fh> ) {
    my @F = split;
    if ( /^\[INFO/ ) {
        my $hour = substr "$_", 18, 2; 
        if ( $#F > 3 ) {
            if ( grep { $F[3] eq "\[$_" } @methods ) {
                $H{$hour}{$F[3]}++;
            }
            else {
                $H{$hour}{ERROR}++;
                push @errors, $_;

            }
        }
    }
}

#title 
print "methods stat in $log\n\n";
printf " "x5;
foreach my $method ( sort @methods ) {
    printf "%12s", $method;
    print " ";
}
printf "%12s", "other";
print "\n";

# content
foreach my $hour ( sort keys %H  ) {
    printf "%s:00", $hour ;
    print " ";
    foreach my $method ( sort @methods ) {
        printf "%12s", $H{$hour}{"\[$method"} || "0" ;
        print " ";
    }
    printf "%12s", $H{$hour}{ERROR} || "0" ;
    print "\n";
}

# if ( @errors ) {
#     print "\n";
#     print "other/errors:\n";
#     print @errors;
# }
