#!/usr/bin/perl
#===============================================================================
#
#         FILE: diffshow.pl
#
#        USAGE: ./diffshow.pl  
#
#  DESCRIPTION: 海燕要求,diff two files, output also twofiles, list the differences. 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/13/2013 11:14:11 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

open my $fhfoo, "< /home/kk/Downloads/foo.csv" || die "$!" ;
open my $fhbar, "< /home/kk/Downloads/bar.csv" || die "$!" ;
open my $output, ">> /home/kk/Downloads/output.txt" || die "$!" ;


sub getfooid {
my %hashfoo;
while ( <$fhfoo> ) {
#    my $id ;
#    next if /CAE_POINT/;
#    print $1 if /(?=HJCOM.*==)(\d+?)(?<=\s)/;
     #$hashfoo{$1}++ if /T200P(\d+)\s/;
     if ( /CAE_POINT/ ){
        next ;
     };
     if ( /T200P(\d+)\s/ ){
        $hashfoo{$1}++;
        next ;
     };
     #$hashfoo{$1}++ if /HJCOM.*==(\d+)\s/;
     if (  /HJCOM.*==(\d+)\s/ ) {
        $hashfoo{$1}++ ;
        next ;
     }
    print $output "foo string error:\tline: ", $., "\t", $_ ;
}


#-------------------------------------------------------------------------------
#  print the hash
#-------------------------------------------------------------------------------

#print $output "count for foo\n";
#while ( my ($k,$v) = each %hashfoo ) {
##    print $k , "\n" if $v == 1 ;
#    print $output $k , "\t", $v,  "\n";
#}
return %hashfoo
} ## --- end sub getfooid

my%fooresult = &getfooid ;



sub getbarid {
my %hashbar ;
while ( <$fhbar> ) {
    #$hashbar{$1}++ if /^(\d+)\s/;
    if ( /^(\d+)\W/ ) {
        $hashbar{$1}++ ;
        next ;
    }
    print $output "bar string error:\tline: ", $., "\t", $_ ;
}
#-------------------------------------------------------------------------------
#  print the hash
#-------------------------------------------------------------------------------
#print $output "count for bar\n";
#while ( my ($k, $v) = each %hashbar ) {
#    print $output $k , "\t", $v,  "\n";
#}
    return %hashbar;
} ## --- end sub getbarid

my%barresult = &getbarid ;






sub difftwofile {
    use Array::Utils qw(:all);
    my	%hashfoo = %{shift()};
    my %hashbar = %{shift()} ;
    my @keysfoo = keys %hashfoo ;
    my @keysbar = keys %hashbar ;
    print $output "foo validated number: ", ~~@keysfoo, "\n";
    print $output "bar validated number: ", ~~@keysbar, "\n";

    # symmetric difference
    my @diff = array_diff(@keysfoo, @keysbar);

    # intersection
    my @isect = intersect(@keysfoo, @keysbar);

    # unique union
    my @unique = unique(@keysfoo, @keysbar);

    # get items from array @keysfoo that are not in array @keysbar
    my @foominusbar = array_minus( @keysfoo, @keysbar );
    my @barminusfoo = array_minus( @keysbar, @keysfoo );

    # check if arrays contain same members
#    if ( !array_diff(@keysfoo, @keysbar) ) {
#        print $output "foo - bar\n" ;
#        print $output "$_\n" for @foominusbar ;
        print $output "bar - foo\n" ;
        print $output "$_\n" for @barminusfoo ;

#    } else {
#        print $output "ids are same" ;
#    }
#    elsif ( @unique ) {
#        print $output "unique\n";
#        print $output "$_\n" for @unique ;
#    }



    return ;
} ## --- end sub difftwofile

&difftwofile(\%fooresult, \%barresult);
