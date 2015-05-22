#
#===============================================================================
#
#         FILE: Horse.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 05/21/2015 05:01:13 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
 
package Horse ;

our @ISA = "Critter";

sub new {
        my $invocant = shift;
        my $class = ref($invocant) || $invocant;
        my $self = {
                color => "bay",
                legs => 4,
                owner => undef,
                @_,         # 覆盖以前的属性
        };
        return bless $self, $class;
}

1
