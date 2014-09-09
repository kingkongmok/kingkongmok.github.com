#!/usr/bin/perl
#===============================================================================
#
#         FILE: http_build_query.pl
#
#        USAGE: ./http_build_query.pl  
#
#  DESCRIPTION: to build http url query by using %hash
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/26/2013 05:10:08 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


#===  FUNCTION  ================================================================
#         NAME: http_build_query
#      PURPOSE: build http url query using cgi %vals
#   PARAMETERS: %vals
#      RETURNS: $querystring
#  DESCRIPTION: 
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub http_build_query {
   my ( $vals ) = @_;
   return join("&", map { "$_=$vals->{$_}" } keys %$vals);
}

#my $query_string = http_build_query({'username'=>'kk','password'=>'oo'});
#print $query_string;

