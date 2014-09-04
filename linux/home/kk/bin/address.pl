#!/usr/bin/perl
#===============================================================================
#
#         FILE: address.pl
#
#        USAGE: ./address.pl  
#
#  DESCRIPTION: check physical address from ip138.com
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/20/2014 02:45:45 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my @result = qx#curl -s "http://www.ip138.com/ips138.asp?ip=@ARGV&action=2" | iconv -f gbk -t utf8# ;
foreach my $line (@result)  {
    print "@ARGV\t$1\n" if $line =~ /数据：(.*?)\</ ;
}

