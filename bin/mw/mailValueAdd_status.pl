#!/usr/bin/env perl 

use strict;
use warnings;
use feature 'say';

my $log= "/home/logs/mailValueAddService/mailValueAddService.log";
$log = $ARGV[0] if $ARGV[0];
my $fh ;
if ( $log =~ /gz$/ ) {
    open $fh, "zcat $log|" || die $!;
}
else {
    open $fh,$log || die $!;
}
my %methods = (
    "UserServiceChangePool" => "addData",
    "UserRightsManagerServlet" => "access",
    "ValueAddMsgSevlet" => "heartbeat",
    "UserInfoServiceImpl" => "Socket", 
    "ExternalMethod" => "userInfoReg",
    "PsServService" => "ps",
    "ValueAddManagerService" => "valueAdd",
    "UMSService" => "ums",
    "InnerDataUpdateService" => "innerDataUpd",
    "ManagerServiceDB" => "db",
    # "MailCaiYunPanPool" => "caiyunPool",
    # "MailCaiYunPanService" => "caiyunSer",
    # "ValueAddSeriveUnsubscribeTask" => "unsubscr",
    # "ValueAddServiceTimeWillExpireTask" => "expire",
    # "ValueaAddSeriveWillSMSTask" => "sms",
);

my %H;
while ( <$fh> ) {
    my @F = split;
    if ( length > 20 ) {
        if ( /\d{4}-\d{2}-\d{2}\s+(\d{2}):\d{2}:\d{2},\d{3}\s+\[INFO\s?\]\s\(.*?(\w+):\d+\)/ ) {
            my $method = $2; 
            my $hour = $1 ;
            if ( grep { $method =~ "$_" } keys %methods ) {
                $H{$1}{$2}++ ;
            }
            else {
                $H{$hour}{ERROR}++;
            }
        }
    }
}

# use Data::Dumper;
# print Dumper \%H;

#title 
print "methods stat in $log\n\n";
printf " "x5;
foreach my $k ( sort keys %methods ) {
    printf "%9s", $methods{$k};
    print " ";
}
printf "%9s", "other";
print "\n";

# content
foreach my $hour ( sort keys %H  ) {
    printf "%s:00", $hour ;
    print " ";
    foreach my $method ( sort keys %methods ) {
        printf "%9s", $H{$hour}{"$method"} || "0" ;
        print " ";
    }
    printf "%9s", $H{$hour}{ERROR} || "0" ;
    print "\n";
}
use Data::Dumper;
print "\n", Dumper \%methods;
