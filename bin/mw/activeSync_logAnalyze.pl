#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use POSIX 'strftime';

my $thisHour = "";
#my $yesterday_thisHour = strftime "%F-%H", localtime (time - 24*60*60 ) ;
my $lastHour = strftime "%F-%H", localtime (time - 60*60) ;
my $yesterday_lastHour = strftime "%F-%H", localtime (time - 24*60*60 - 60*60);
my $beforeLastHour = strftime "%F-%H", localtime (time - 2*60*60) ;
#my $yesterday_beforeLastHour = strftime "%F-%H", localtime (time - 24*60*60 - 2*60*60) ;

#my @logs_suffix = ( $thisHour, $lastHour, $beforeLastHour, $yesterday_thisHour,
#    $yesterday_lastHour, $yesterday_beforeLastHour );
my @logs_suffix = ( $thisHour, $lastHour, $beforeLastHour );

my @methods = ( "FolderCreate", "Settings", "FolderSync", "Sync", "Ping");

my %activeSyncMethods ;
foreach my $suffix ( @logs_suffix ) {

    my $logname = "/home/logs/activeSync/activesync.log";
    $logname .= $suffix ? ".$suffix" : $suffix;
    print "analyzing $logname, please wait...\n";
    my $methodsSum = 0;
    my $infoSum = 0;

    open my $fh, $logname || die $! ;
    while ( <$fh> ) {
        my @F = split;
        if ( /\[INFO\].*activeSyncMethod: (.*)/ ) {
            if ( my @match = grep {$_ eq $1} @methods ) {
                $activeSyncMethods{$match[0]}{$suffix}++;
            }
        }
        if ( /\[\w+?\]/ ) {
            $methodsSum++;
            if ( /\[INFO\]/ ) {
                $infoSum++;
            }
            $activeSyncMethods{$F[2]}++
        }
    }
    my $successPercent = sprintf "%.2f", 100*$infoSum/$methodsSum || 0;
    $activeSyncMethods{success}{$suffix}= $successPercent;
}

print "\n\n";
print "'activeSyncMethod: \$METHOD' on logfile, and counting by hourly: " ,
"and get success percentage.\n\n";

print " "x16;
foreach my $method ( @methods  ) {
    printf "%14s",$method;
}
printf "%14s","SuccessPerc";
my $thisTab = "thisHour";
print "\n";

printf "%13s",$thisTab;
foreach my $suffix ( @logs_suffix ) {
    print $suffix, "\t"; 
    foreach my $method ( @methods ) {
        printf "%14s",$activeSyncMethods{$method}{$suffix} ?
        $activeSyncMethods{$method}{$suffix} : 0; 
    }
    printf "%14s%%",$activeSyncMethods{success}{$suffix};
    print "\n";
}
