#!/usr/bin/env perl 

use strict;
use warnings;

my @logs= glob "/logs/pnsMsg/172.16.210.10*/cardDav/caldavSync.log";

my %methods = ( 
    "getUserPartID" => "UserPartID",
    "calendarQuery" => "calQuery",
    "info"=> "info",
    "checkPwd"=> "checkPwd",
    "checkUserSms"=>"checkUSms",
    "calendarMultiget" => "calMulti",
    "propertyupdate" => "propUpdate",
);

my %H;
foreach my $log ( @logs ) {
    my $fh ;
    if ( $log =~ /gz$/ ) {
        open $fh, "zcat $log|" || die $!;
    }
    else {
        open $fh,$log || die $!;
    }
    while ( <$fh> ) {
        my @F = split;
        if ( /^\[INFO/ ) {
            my $hour = substr "$_", 18, 2; 
            if ( $#F > 3 ) {
                if ( grep { $F[3] eq "\[$_" } sort keys %methods ) {
                    $H{$hour}{$F[3]}++;
                }
                else {
                    $H{$hour}{ERROR}++;
                }
            }
        }
    }
}

#title 
print "methods stat in @logs\n\n";
printf " "x5;
foreach my $k ( sort keys %methods ) {
    printf "%12s", $methods{$k};
    print " ";
}
printf "%12s", "other";
print "\n";

# content
foreach my $hour ( sort keys %H  ) {
    printf "%s:00", $hour ;
    print " ";
    foreach my $method ( sort keys %methods ) {
        printf "%12s", $H{$hour}{"\[$method"} || "0" ;
        print " ";
    }
    printf "%12s", $H{$hour}{ERROR} || "0" ;
    print "\n";
}

use Data::Dumper;
print "\n", Dumper \%methods; 
