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
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 06/10/2015 11:03:53 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use feature 'say';

my ( $handleref,  $coderef,  $hashref,  $arrayref, $bar, $foo, $scalarref, $camel_model, $filename );
$foo = "three humps";
$scalarref = \$foo; # $scalarref is now a reference to $foo
$camel_model = $$scalarref; # $camel_model is now "three humps"

$bar = $$scalarref;
push(@$arrayref, $filename);
$$arrayref[0] = "January"; # Set the first element of @$arrayref
@$arrayref[4..6] = qw/May June July/; # Set several elements of @$arrayref
%$hashref = (KEY => "RING", BIRD => "SING"); # Initialize whole hash
$$hashref{KEY} = "VALUE"; # Set one key/value pair
@$hashref{"KEY1","KEY2"} = ("VAL1","VAL2"); # Set two more pairs
&$coderef(1,2,3);
say $handleref "output";
