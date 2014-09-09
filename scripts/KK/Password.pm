#
#===============================================================================
#
#         FILE: private.pm
#
#  DESCRIPTION: file to restore username and password.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/25/2013 05:20:42 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
 

#===  FUNCTION  ================================================================
#         NAME: getpassword
#      PURPOSE: get username, passwod and so on
#   PARAMETERS: 
#      RETURNS: %passwd
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getpassword {
    my %password ;
    open FH, "< /home/kk/.kk_var" || die $! ;
    my @file = readline FH ;
    foreach my $line ( @file ) {
        if ( $line =~ /COMMON_USERNAME=(\S+)/ ) {
            $password{kk}{username}=$1 ;
            next ;
        }
        if ( $line =~ /COMMON_PASSWORD=(\S+)/ ) {
            $password{kk}{password}=$1 ;
        }
        if ( $line =~ /COMMON_WEBUSERNAME=(\S+)/ ) {
            $password{us}{username}=$1 ;
        }
        if ( $line =~ /US_SERVER_ADDRESS=(\S+)/ ) {
            $password{us}{address}=$1 ;
        }
        
    }
    return %password;
} ## --- end sub passwd

1 ;
