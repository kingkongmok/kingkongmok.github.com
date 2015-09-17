#!/usr/bin/perl
use strict;                                  
use warnings;
use Data::Dumper;                            
#use Encode qw/encode decode/;                
#use utf8;

my $logfile = "/home/logs/peAgent/peAgent.log";

#open my $fh, '-|:encoding(gbk)',  "tail -c 300m $logfile" || die $!; 
open my $fh, "tail -c 500m $logfile |" || die $!; 


my %H;
my %count;
while ( <$fh> ) {

    # print if /-99/;
    # print if /帐单通知返回结果:(.*?)\|/;
    if ( /帐单通知返回结果:(.*?)\|/ ) {
        my $thisTime = substr $_,11,4;
        $H{$thisTime}{$1}++;
        $count{$thisTime}++;
    }

}

#print Dumper \%H;

# print header;
printf "time:\t";
foreach my $method ( (0,-1,-2,-99) ) {
    printf "%9s\t", $method
}
printf "%9s", "percent"; 
print "\n";

my @times = sort keys%H;
# cut 1st line. 
shift @times ;

# print contents
foreach my $time ( @times ) {
    printf "%s0:\t", $time;
    my $sum = 0 ;
    foreach my $method ( (0,-1,-2,-99) ) {
        my $column = $H{$time}{$method} || 0;
        printf "%9s\t", $column;
        $sum += $column;
    }
    my $percent = $count{$time} ? sprintf "%9.2f%%",$sum*100/$count{$time} :
    sprintf "%9s","na";
    print $percent;
    print "\n";
}
