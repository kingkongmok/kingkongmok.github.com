#!/usr/bin/perl
#===============================================================================
#
#         FILE: crud.pl
#
#        USAGE: ./crud.pl  
#
#  DESCRIPTION: test CRUD in DBI::MYSQL
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/14/2014 02:37:28 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use CGI;
use DBI;
use CGI::Carp qw/fatalsToBrowser/;
use CGI::Session;

my $session   = CGI::Session->new or die CGI::Session->errstr;
my $cgi       = CGI->new;
my %vars     = $cgi->Vars;
$session->clear if $cgi->param('logout');
$session->param('hostname', `hostname`);


my $cgi = new CGI ;


sub user_authenticated {
   if ( defined $vars{'username'} && defined $vars{'password'} ) {
    my ( $dsn , $user, $password )= ("dbi:mysql:test", "kk", "kk") ;
    my $dbh = DBI->connect($dsn, $user, $password, ) || die "connect error";
      my ($pass, $roll, $name) = ("123456", "roll", "kk");
      if ( $pass ) {
         my $password=  $vars{'password'};
         if ( $password eq $pass ) {
            $session->clear('login_failed');
            $session->param('logged_in', 1);
            $template->param('logged_in', 1);
            $session->param('admin', $vars{'username'});
            $session->param('roll', $roll);
            $session->param('gic', 1) if $roll eq 'admin';
            return 1;
         }
      }
   }
   return 0;
}

