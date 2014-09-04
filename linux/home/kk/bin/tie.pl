#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
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
#      CREATED: 10/12/2013 11:23:24 AM
#     REVISION: ---
#===============================================================================

#use strict;
#use warnings;

package Centsible;
sub TIESCALAR { bless \my $self, shift } ;
sub STORE { ${ $_[0] } = $_[1] } ;
sub FETCH { sprintf "%.02f", ${ my $self = shift } } ;

package main;
tie $bucks, "Centsible";
$bucks = 45.00;
$bucks *= 1.0715; # tax
$bucks *= 1.0715; # and double tax!
print "That will be $bucks, please.\n";

