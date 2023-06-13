#!/usr/bin/env perl 

use strict;
use warnings;

my %methods = ( "tid" => "tid",
    "333333333333333333" => "33333",
    "222222222222"=> "22222",
    "111111111111111111111111111111111"=> "11111" ,
    "doPropfindOutlook" => "findOutlook",
    "APIServer" => "checkpwd",
    "getJsonContacts" => "jsonContact",
    "doPut" => "doPut",
);

my @logs= glob "/logs/pnsMsg/172.16.210.10*/cardDav/carddav.log";
my %H;

foreach my $log (@logs  ) {
    my $fh ;
    if ( $log =~ /gz$/ ) {
        open $fh, "zcat $log|" || die $!;
    }
    else {
        open $fh,$log || die $!;
    }
    while ( <$fh> ) {
        my @F = split;
        if ( length > 20 ) {
            if ( /\d{4}-\d{2}-\d{2}\s+(\d{2}):\d{2}:\d{2}-\[INFO\]\s(\w+)(?:=|\|)?/ ) {
                my $hour = $1;
                my $method = $2; 
                #if ( grep { $method =~ "$_" } @methods ) {
                if ( grep {  /$method/ } keys %methods ) {
                    $H{$hour}{$method}++;
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
print "\t";
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
        printf "%12s", $H{$hour}{"$method"} || "0" ;
        print " ";
    }
    printf "%12s", $H{$hour}{ERROR} || "0" ;
    print "\n";
}

use Data::Dumper;
print "\n", Dumper \%methods; 
