#!/usr/bin/perl
#===============================================================================
#
#         FILE: aoh.pl
#
#        USAGE: ./aoh.pl  
#
#  DESCRIPTION: test aoh in perl
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/20/2013 03:18:34 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


my $string="
flintstones: fred barney wilma dino
jetsons:     george jane elroy
simpsons:    homer marge bart
simpsons:    kk kingkong
";

my@aoh=&getaoh($string) ;
    use Data::Dumper;
    print Dumper(\@aoh);


#===  FUNCTION  ================================================================
#         NAME: getaoh
#      PURPOSE: get aoh from string
#   PARAMETERS: $string
#      RETURNS: %aoh
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getaoh {
    my	( $string )	= @_;
    my @aoh;
    my @arrays = split/\n/,$string;
    foreach my $row ( @arrays ) {
        my %hash ;
        if ( $row ) {
            if ( $row =~ /(.*):\s+(.*)/ ) {
                my $key = $1 ;
                my $value = $2 ;
                $hash{$key}=$value ;
            }
            push @aoh, \%hash ;
        }
    }
    return @aoh;
} ## --- end sub getaoh
