#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 05/21/2015 03:43:22 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Critter;
use Data::Dumper;
use Horse;

my $pet = new Critter ;

# my $pet = Critter::spawn("chick");
#
# print ref $pet ;
print Dumper $pet ;

 my $ed    = Horse->new;                          # 四腿湾马
# my $stallion = Horse->new( "color" => "red"); # 四腿黑马

 print Dumper \$ed; 
