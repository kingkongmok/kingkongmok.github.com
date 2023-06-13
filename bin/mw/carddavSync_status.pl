#!/usr/bin/env perl 

use strict;
use warnings;

my $log= "/home/logs/cardDav/carddav.log";
$log = $ARGV[0] if $ARGV[0];
my $fh ;
if ( $log =~ /gz$/ ) {
    open $fh, "zcat $log|" || die $!;
}
else {
    open $fh,$log || die $!;
}
my @methods = ( "tid", "333333333333333333", "222222222222", "111111111111111111111111111111111", "doPropfindOutlook", "APIServer", );

my %H;
my @errors;
while ( <$fh> ) {
    my @F = split;
    if ( length > 20 ) {
        if ( /\d{4}-\d{2}-\d{2}\s+(\d{2}):\d{2}:\d{2}-\[INFO\]\s(\w+)=?/ ) {
            my $hour = $1;
            my $method = $2; 
            #if ( grep { $method =~ "$_" } @methods ) {
                if ( grep {  /$method/ } @methods ) {
                    $H{$hour}{$method}++;
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
        printf "%12s", $H{$hour}{"$method"} || "0" ;
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
