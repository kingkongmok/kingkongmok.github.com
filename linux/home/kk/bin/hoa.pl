#!/usr/bin/perl 
#===============================================================================
#
#         FILE: hoa.pl
#
#        USAGE: ./hoa.pl  
#
#  DESCRIPTION: test hash of array, sepcial for the elements added at the last.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/18/2013 10:53:19 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper ;

my $string="
flintstones: fred barney wilma dino
jetsons:     george jane elroy
simpsons:    homer marge bart
simpsons:    kk kingkong
";


my%hoa=&gethoa($string);

for (&showhoaelements(\%hoa)){
    local $\="\n";
    print ;
};



#===  FUNCTION  ================================================================
#         NAME: gethoa
#      PURPOSE: get %hoa from the string.
#   PARAMETERS: $string
#      RETURNS: %hoa
#  DESCRIPTION: string split by /:/ and make prefix as key, suffix as [values].
#               if $hoa{key} exists, joins the values to the [values];
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a #=============================================================================== 
sub gethoa {
    my %hoa;
    my	( $par1 )	= @_;
    foreach my$line ( split/\n/,$par1 ) {
        next if $line =~ /^$/ ;
        if ( $line=~/(.+?):\s+(.+)/ ) {
            my$k=$1;
            my$v=$2;
            if ( exists$hoa{$k} ) {
                my@temp=@{$hoa{$k}};
                my@preresult=&joinarray(\@temp,$v);
                $hoa{$k}=[@preresult] ;
            }
            else {
                $hoa{$k}=[split/\s+/,$v];
            }
        }
    }


    return %hoa;
} ## --- end sub gethoa

#===  FUNCTION  ================================================================
#         NAME: showhoaelements
#      PURPOSE: get  
#   PARAMETERS: %hoa
#      RETURNS: @array
#  DESCRIPTION: get all %hoa values and push all of these into @array
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub showhoaelements {
    my	( $par1 )	= @_;
    my @array ;
    while ( my($k,$v)=each%$par1 ) {
#        local $\="\n";
        for ( my $idx=0; $idx<5; $idx++ ) {
             push @array, $v->[$idx] if $v->[$idx] ;
        }
    }
    return @array;
} ## --- end sub showhoaelements

#===  FUNCTION  ================================================================
#         NAME: joinarray
#      PURPOSE: join elements to array
#   PARAMETERS: @array, $elements
#      RETURNS: @newarray
#  DESCRIPTION: split the elements with space then push to the array
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub joinarray {
    my	@array = @{shift()};
    my	$elements = shift;
    foreach my $element ( split/\s+/,$elements ) {
        push @array,$element;
    }
    return @array ;
} ## --- end sub joinarray
