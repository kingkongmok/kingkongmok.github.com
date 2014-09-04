#!/usr/bin/perl
#===============================================================================
#
#         FILE: cookie.pl
#
#        USAGE: ./cookie.pl  
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
#      CREATED: 10/23/2013 02:48:20 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;
use CGI::Carp qw/fatalsToBrowser/;
use CGI::Cookie ;

my $q = new CGI;

if ( $q->param("cookie") ) {
    &setCookies;
}
else {
    if ( my %cookies=CGI::Cookie->fetch ) {
        if (&checkCookie(\%cookies)){
            &showCookiePref(\%cookies) ;
        }
    }
    else {
        &printHeaderCookie ;
    }
}

sub printHeaderCookie {
    my $cookie1 = CGI::Cookie->new(-name=>'ID',-value=>123456);
    my $cookie2 = CGI::Cookie->new( -name=>'preferences', 
        -value=>{ 
            font => "Helvetica",
             size => 12 ,
         }  );
    print $q->header(-cookie=>[$cookie1,$cookie2]), 
        "hello stranger, please enable cookies.\n";
    return 0;
}

sub checkCookie {
    if (my	%cookies = %{shift()} ){ 
        my $id = $cookies{ID}->value ;
        return 1 if $id == '123456' ;
    }
    return 0;
} ## --- end sub checkCookie


sub showCookiePref {
    if (my  %cookies = %{shift()} ){
        my%hash = $cookies{preferences}->value;
        print $q->header; 
        while ( my($k,$v)=each%hash ) {
            print "you\'re $k is $v\n" ;
        }
    }
    return 1;
} ## --- end sub showCookiePref


sub setCookies {
    my @names = $q->param ;
    my %cookie;
    foreach  (@names) {
        $cookie{$_}=$q->param($_);
    }
    my $cookies = CGI::Cookie->new( -name=>"name",
    -value=>\%cookie);
        print $q->header(-cookie=>$cookies);;
    return 0;
} ## --- end sub setCookies

#sub showDemoCookie {
#    print $q->header, "hello";
#    my%cookies = %{shift()};
#    my $cookie1 = CGI::Cookie->new(-name=>'ID',-value=>123456);
#    my $cookie2 = CGI::Cookie->new( -name=>'preferences', 
#        -value=>{ 
#            font => "Helvetica",
#             size => 12 ,
#         }  );
#    my$id = $cookies{'ID'}->value;
#    my%hash = $cookies{'preferences'}->value;
#    print $q->header(-cookie=>[$cookie1,$cookie2]),
#    "you had cookie\n",
#    "the demo cookie ID is $id\n",
#    "and the demo cookie is below\n",
#    while ( my($k,$v)=each%hash ) {
#        "$k\t$v\n" ;
#    }
#    return 1;
#}
