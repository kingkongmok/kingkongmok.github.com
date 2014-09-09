#!/usr/bin/perl -l
#===============================================================================
#
#         FILE: methodtesting.pl
#
#        USAGE: ./methodtesting.pl  
#
#  DESCRIPTION: test the *my* and *local* scope.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 02/14/2014 02:35:33 PM
#     REVISION: ---
#===============================================================================


$lo='global';$m  = 'global'; 
A();

sub A { 
  local $lo='AAA';       my$m  = 'AAA'; 
  B(); 
}

sub B { 
    print "B ", ($lo eq 'AAA' ? 'can' : 'cannot') , 
    " see the value of lo set by A. the value is ", $lo;

    print "B ", ($m  eq 'AAA' ? 'can' : 'cannot') , 
    " see the value of m  set by A. the value is ", $m; 
}
