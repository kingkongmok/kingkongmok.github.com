#!/usr/bin/perl
#===============================================================================
#
#         FILE: cgidump.pl
#
#        USAGE: ./cgidump.pl  
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
#      CREATED: 10/22/2013 02:48:54 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;
use CGI::Carp qw/fatalsToBrowser/;
my $q = new CGI;
my @keys = $q->param();
my $errors ;
$errors = validation($errors, \@keys);

sub validation($) {
    my $newerrors = shift ; 
    my	( $par1 )	= shift ;
    for ( @$par1 ) {
       $newerrors++ if /^name$/ ; 
    }
    return $newerrors;
} ## --- end sub validation

my $name =  $q->param("name");
print $q->header(-charset=>"utf-8");
if ( $errors > 0 ) {
    print $q->p("errors is $errors");
} else {
    print $q->p("your name is $name");
}
