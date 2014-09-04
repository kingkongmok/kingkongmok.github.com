#!/usr/bin/perl
#===============================================================================
#
#         FILE: methodtesting.pl
#
#        USAGE: ./methodtesting.pl  
#
#  DESCRIPTION: http://perlmonks.org/?node_id=647153
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 02/14/2014 04:56:06 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

=usage
    reduce \&f @x;
eg.
    reduce {$a+$b} @x;      # sum @x
    reduce {$a*$b) 1..7     # factorial(7) = 7!
=cut

sub reduce (&@)
{ my $f = shift;
  local ($a, $b) = shift;
  $a=&$f while $b=shift;
  return $a;
}

my $x = reduce { $a+$b } 1..7;
print $x;
