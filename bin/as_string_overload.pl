#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./as_string_overload.pl
#
#  DESCRIPTION: Overloadable
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 12/22/2014 11:32:07 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

package Person;
#use overload q("") => \&as_string;
use overload q("") => \&as_string;
sub new {
    my $class = shift;
    return bless { @_ } => $class;
}
sub as_string {
    my $self = shift;
    my ($key, $value, $result);
    while (($key, $value) = each %$self) {
        $result .= "$key => $value\n";
    }
    return $result;
}
my $obj = Person->new(height => 72, weight => 165, eyes => "brown");
print $obj;
