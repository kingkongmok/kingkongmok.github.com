#!/usr/bin/perl 
#===============================================================================
#
#         FILE: paste.pl
#
#        USAGE: ./paste.pl  
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
#      CREATED: 09/11/2013 05:30:18 PM
#     REVISION: ---
#===============================================================================

#use strict;
#use warnings;

open F1,"<","/home/kk/1";
open F2,"<","/home/kk/2";

chomp(my@a=<F1>);
chomp(my@b=<F2>);

 map {($a[$_], $b[$_])} ~~@a
