#!/usr/bin/perl
#===============================================================================
#
#         FILE: hoh.pl
#
#        USAGE: ./hoh.pl  
#
#  DESCRIPTION: test for hoh
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/19/2013 12:20:37 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my$string="
flintstones: fred barney wilma dino
flintstones: barney wilma dino
jetsons:     george jane elroy
jetsons:     george jane elroy 2
jetsons:     george jane elroy 3
simpsons:    homer marge bart
simpsons:    marge bart
simpsons:    fred kingkong
";

my%hoh;
%hoh=&strToHoh($string);
#&tocsv(\%hoh);
&toxls(\%hoh);



#===  FUNCTION  ================================================================
#         NAME: strToHoh
#      PURPOSE: make %hoh from string
#   PARAMETERS: $string
#      RETURNS: %hoh
#  DESCRIPTION: at first split/:/ and make $1 as hoh, and then split/\s+/,value
# ,2 split the $value to two block.
# merge if hoh is exists.
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub strToHoh {
    my	$string	= shift;
    my @input = split/\n/,$string ;
    my %hash ;
    foreach my $line ( @input ) {
        if ( $line =~ /(.+):\s+(.*)/ ) {
            my$k=$1;
            my$v=$2;
            my($hohkey,$hohvalue) = split(/\s+/,$v,2);
            if ( exists $hash{$k}{$hohkey} ) {
                $hash{$k}{$hohkey}=join" ",($hash{$k}{$hohkey},$hohvalue);
            }
            else {
                $hash{$k}{$hohkey}=$hohvalue;
            }
        }
    }
    return %hash;
} 

#===  FUNCTION  ================================================================
#         NAME: tocsv
#      PURPOSE: print out to csv format
#   PARAMETERS: %hoh
#      RETURNS: 
#  DESCRIPTION: print out the csv format, using "",""
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub tocsv {
#    local $\=",";
#    local $,=",";
    my	%hoh = %{shift()};
    while ( my($hashskey,$hashsvalue)=each%hoh ) {
        while ( my($key,$value)=each%{$hashsvalue} ) {
            foreach my $v ( split/\s+/,$value ) {
                print "\"", $hashskey, "\",\"",  $key, "\",\"",  $v, "\'\n" ;
            }
        }
    }
    return 1;
} ## --- end sub tocsv


#===  FUNCTION  ================================================================
#         NAME: toxls
#      PURPOSE: output as xls
#   PARAMETERS: %hoh
#      RETURNS: 
#  DESCRIPTION: outout as xls, print hoh's key as row and hashs' key as column.
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub toxls {
    my	%hoh = %{shift()};
    #local $\="\n";
    print "BEGIN";
    my@rows;
    my@columns;
    my%temp0;
    my%temp1;
    foreach my $hohkeys ( sort keys %hoh ) {
        print ",$hohkeys" ;
        push @rows,$hohkeys ;
        foreach my $keys ( sort keys $hoh{$hohkeys} ){
            push @columns, $keys;
        }
    }
    print "\n";
    @temp0{ @columns }=();
    my@column = keys%temp0;
    @temp1{ @rows }=();
    my@row = keys%temp1;
    foreach my $row ( @row ) {
        print "$row," ;
        foreach my $column ( @column ) {
            if ( $hoh{$row}{$column} ) {
                print "$hoh{$row}{$column}" ;
            }
            else {
                print "0," ;
            }
        }
        print "\n" ;
    }
    return ;
} ## --- end sub toxls

