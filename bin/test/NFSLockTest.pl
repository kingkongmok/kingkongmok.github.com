#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: NFSLockTest.pl
#
#        USAGE: ./NFSLockTest.pl  
#
#  DESCRIPTION: Running only one Perl script instance by cron
#               http://stackoverflow.com/questions/2232860/running-only-one-perl-script-instance-by-cron
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 02/17/2016 03:21:42 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use feature 'say';

use Fcntl qw(LOCK_EX LOCK_NB);
use File::NFSLock;

# Try to get an exclusive lock on myself.
my $lock = File::NFSLock->new($0, LOCK_EX|LOCK_NB);
die "$0 is already running!\n" unless $lock;

sleep 1000;
