#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test2.pl
#
#        USAGE: ./test2.pl  
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
#      CREATED: 07/02/2015 12:09:42 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use feature 'say';

use Getopt::Long;

# setup my defaults
my $name     = 'Bob';
my $age      = 26;
my $employed = 0;
my $help     = 0;

GetOptions(
    'name=s'    => \$name,
    'age=i'     => \$age,
    'employed!' => \$employed,
    'help!'     => \$help,
) or die "Incorrect usage!\n";

if( $help ) {
    print "Common on, it's really not that hard.\n";
} else {
    print "My name is $name.\n";
    print "I am $age years old.\n";
    print "I am currently " . ($employed ? '' : 'un') . "employed.\n";
}
