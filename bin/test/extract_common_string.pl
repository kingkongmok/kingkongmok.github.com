#!/usr/bin/perl 
#===============================================================================
#
#         FILE: comm.pl
#
#        USAGE: ./comm.pl  
#
#  DESCRIPTION: to extract the common string from two string 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 09/11/2013 10:20:29 AM
#     REVISION: ---
#===============================================================================

#use strict;
#use warnings;

#$first="abcdaaaaaa";
#$second="1234aaa";
#"$first\0$second" =~ m/^.+?(.+)\0.+?\1$/;
#print $1 ;

#$first="aaaaaaABCD";
#$second="aaaba12345";
#"$first\0$second" =~ m/^(.+).+\0\1.+$/;
#print $1 ;

$first="abcdaabaABCD";
$second="1234aaaa5678";
"$first\0$second" =~ m/^.+?(.+).+\0.+?\1.+$/;
print $1 ;
