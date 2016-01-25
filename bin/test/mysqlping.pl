#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: G
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 01/22/2016 02:50:01 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use DBI; 
use DBD::mysql; 

my $address = $ARGV[0] ? $ARGV[0] : "127.0.0.1"; 
my $dsn = "DBI:mysql:database=zabbix;host=$address;port=3306";
my $dbh = DBI->connect($dsn, "zabbix", "zabbixpassword") || die $!;
print $dbh->ping();
