#!/usr/bin/perl
#===============================================================================
#
#         FILE: ddns.pl
#
#        USAGE: ./ddns.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/26/2013 10:03:56 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use lib '/home/kk/bin' ;
use password ;
my%password=&getpassword;

my $result = qx#curl -q "http://$password{us}{username}:$password{kk}{password}\@members.3322.org/dyndns/update?system=dyndns&hostname=$password{us}{username}.3322.org&mx=$password{us}{username}.3322.org" 2>/dev/null #;

#print $result ;


#===  FUNCTION  ================================================================
#         NAME: validate3322
#      PURPOSE: validate 3322's html result
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub validate3322 {
    my $result = shift ;
    if ( $result =~ /(good|nochg)\s+\d+(\.\d+){3}/ ) {
        return 1 ;
    }
    return 0;
} ## --- end sub validate3322

eval {
    &validate3322($result) ;
} || print $@ ;

