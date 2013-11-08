#!/usr/bin/perl

use warnings;
use strict;
use DBI;
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use CGI::Session;
use HTML::Template;
#use Crypt::PasswdMD5;

my $title     = 'Email Administration Login';
my $cgi       = CGI->new;
my $self      = $cgi->url;
my %login     = $cgi->Vars;
my $session   = CGI::Session->new or die CGI::Session->errstr;
my $template  = HTML::Template->new(
                      filename          => '/tmp/login.tmpl',
                      associate         => [$session],
                      die_on_bad_params => 0,
                      global_vars       => 1,
                      cache             => 0,
                );

$session->clear if $cgi->param('logout');
$session->param('hostname', `hostname`);

$SIG{__DIE__} = \&dying;

if ( $cgi->param('Login') ) {
   my $home = './welcome.txt';
   print $cgi->header;
   print $cgi->redirect($home) if user_authenticated();
}

#print $session->header;
#warningsToBrowser(1);
#print $template->output;
print $session->header;
print 
$cgi->param("username"),
$cgi->param("password");



exit;

################################################################################


sub user_authenticated {

   $session->param('login_failed',
                   'Invalid username, or password...Please try again');

   if ( defined $login{'username'} && defined $login{'password'} ) {

      #my ($encrypted_pass, $roll, $name) = queryDB( $login{'username'} );
      my ($pass, $roll, $name) = ("123456", "roll", "kk");

      if ( $pass ) {

         my $password=  $login{'password'};

         if ( $password eq $pass ) {
            $session->clear('login_failed');
            $session->param('logged_in', 1);
            $template->param('logged_in', 1);
            $session->param('admin', $login{'username'});
            $session->param('roll', $roll);
            $session->param('gic', 1) if $roll eq 'admin';
            return 1;
         }
      }
   }
   return 0;
}
