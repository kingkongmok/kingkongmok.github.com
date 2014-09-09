#!/usr/bin/perl
#===============================================================================
#
#         FILE: displayform.pl
#
#        USAGE: ./displayform.pl  
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
#      CREATED: 10/21/2013 04:30:22 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;
my $q = new CGI ;

my $name = $q->param("name") || "stranger" ;
my $age = $q->param("age") ;
my $link ;
my @output = check_param($name, $age) ;
sub check_param {
    my	( $name_out, $age_out , $link_out)	= @_;
    if ( $name ) {
        $name_out = "hello, $name";
    }
    if ( $age > 100 ) {
        $age_out=qq#you're dead#;
    }
    elsif ( $age>18) {
        $age_out= qq#you're $age, please come#;
        $link_out = $q->a({-href=>"cig-bin/adfas.pl"},"$name_out");
    }
    else {
        $age_out="age is not enough 18." ;
    }
    return ($name_out, $age_out, $link_out);
} ## --- end sub check_param

print 
$q->header(-charset=>"utf-8"),
$q->start_html("hello"),
#$age,
$q->p("$output[0]"),
$q->p("$output[1]"),
$q->p("$output[2]"),
$q->end_html;

