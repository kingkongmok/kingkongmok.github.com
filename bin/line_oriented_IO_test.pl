#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: line_oriented_IO_test.pl
#
#        USAGE: ./line_oriented_IO_test.pl
#
#  DESCRIPTION: from http://www.troubleshooters.com/codecorn/littperl/perlfile.htm
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/03/2015 04:09:41 PM
#     REVISION: ---
#===============================================================================

#!/usr/bin/perl -w
use strict;
use Devel::Size qw/total_size size/;

my $bigfileName = "/tmp/bigfile.txt";
my $sipfileName = "/tmp/sip.out";
my $arrayfileName = "/tmp/array.out";
my $slurpfileName = "/tmp/slurp.out";

sub slurp()
    {
    my $inf;
    my $ouf;
    my $holdTerminator = $/;
    undef $/;
    open $inf, "<" . $bigfileName;
    my $buf = <$inf>;
    close $inf;
    $/ = $holdTerminator;
    my @lines = split /$holdTerminator/, $buf;
    $buf = "init";
    $buf = join $holdTerminator, @lines;
    print "slurp's \@line memory ",  total_size(\@lines), "\n";
    open $ouf, ">" . $slurpfileName;
    print $ouf $buf;
    print $ouf "\n";
    close $ouf;
    }

sub testinput()
    {
    my $inf;
    my $ouf;
    open $inf, "<" . $bigfileName;
    open $ouf, ">" . $sipfileName;
    my @lines = <$inf> ;
    print "<>'s \@line memory ",  total_size(\@lines), "\n";
    print $ouf @lines ;
    close $ouf;
    close $inf;
    }

sub readlinetest()
    {
    my $inf;
    my $ouf;
    open $inf, "<" . $bigfileName;
    open $ouf, ">" . $sipfileName;
    my @lines = readline$inf ;
    print "readlinetest's \@line memory ",  total_size(\@lines), "\n";
    print $ouf @lines ;
    close $ouf;
    close $inf;
    }

sub sip()
    {
    my $inf;
    my $ouf;
    open $inf, "<" . $bigfileName;
    open $ouf, ">" . $sipfileName;
    while(<$inf>)
    {
    my $line = $_;
    chomp $line;
    print $ouf $line, "\n";
    
    }
    close $ouf;
    close $inf;
    }

sub buildarray()
    {
    my $inf;
    my $ouf;
    my @array;
    open $inf, "<" . $bigfileName;
    while(<$inf>)
    {
    my $line = $_;
    chomp $line;
    push @array, ($line);
    }
    print "buildarray's \@line memory ",  total_size(\@array), "\n";
    close $inf;
    open $ouf, ">" . $arrayfileName;
    foreach my $line (@array)
    {
    print $ouf $line, "\n";
    }
    close $ouf;
    }

sub main()
    {
    my $time1 = time();

    print "Starting sip\n";
    sip();
    print "End sip\n";

    my $time2 = time();

    print "Starting array\n";
    buildarray();
    print "End array\n";

    my $time3 = time();

    print "Starting slurp\n";
    slurp();
    print "End slurp\n";


    my $time4 = time();

    print "Starting readlinetest\n";
    readlinetest();
    print "End readlinetest\n";

    my $time5 = time();

    print "Starting <>\n";
    testinput();
    print "End <>\n";

    my $time6 = time();

    print "Sip time is ", $time2-$time1, " seconds\n";
    print "Array time is ", $time3-$time2, " seconds\n";
    print "Slurp time is ", $time4-$time3, " seconds\n";
    print "readlinetest time is ", $time5-$time4, " seconds\n";
    print "<> time is ", $time6-$time5, " seconds\n";
    }

main();

