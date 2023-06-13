#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: check_ipvs.pl
#
#        USAGE: ./check_ipvs.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 09/23/2015 03:58:31 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use feature 'say';


open my $fh , "/etc/keepalived/keepalived.conf" || die $! ;

my @config_vs;
my @config_rs;

while ( <$fh> ) {
    #real_server 2409:8080:0:1000:0:2:52F1:0119 8192 {
    push @config_rs, "$1:$2"  if /real_server\s+(\d\S+)\s+(\S+)(?:\b|\{)/;
    push @config_vs, "$1:$2"  if /virtual_server\s+(\d\S+)\s+(\S+)(?:\b|\{)/;
}

my @ipvs_result = qx{sudo /sbin/ipvsadm -L -n};
exit if $?;
my @ipvs_vs;
my @ipvs_rs;
foreach my $ipvs ( @ipvs_result  ) {
    push @ipvs_vs, $1 if $ipvs =~ /(?:TCP|UDP)\s+(\d\S+)\s+\w*/;
    push @ipvs_rs, $1 if $ipvs =~ /->\s+(\d\S+)\s+\w*/;
}

# print Dumper \@ipvs_vs;
# print Dumper \@ipvs_rs;

print "\n";
print "virtualserver failed list:\n";
foreach my $vs ( @config_vs ) {
     print "$vs\n" unless grep { $_ eq $vs } @ipvs_vs;
}
print "\n";
print "\n";
print "realserver failed list:\n";
foreach my $rs ( @config_rs ) {
     print "$rs\n" unless grep { $_ eq $rs } @ipvs_rs;
}
