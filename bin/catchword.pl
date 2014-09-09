#!/usr/bin/perl
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
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/21/2014 11:21:31 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

while ( <> ) {
    chomp ;
    if ( /(?<words>\b\w*a\b)/ ) {
        print "match: |$`<$&>$'|\n" ;
        print "'words' contains '$+{words}'\n";

        use Data::Dumper;
        print Dumper(\%+);

    }

}
