#!/usr/bin/perl
#===============================================================================
#
#         FILE: adduser.pl
#
#        USAGE: ./adduser.pl  
#
#  DESCRIPTION: add user to Mysql::test::user by cgi and dbi.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/05/2014 10:59:17 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my $q = new CGI ;

my $name = $q->unescape($q->param("name")) ;
my $sex = $q->unescape($q->param("sex")) ;
my $birth = $q->unescape($q->param("birth")) ;

my $dsn = "dbi:mysql:test" ;
my $user = "kk" ;
my $password = "kk" ;

my $dbh = DBI->connect($dsn, $user, $password,  {AutoCommit=>0, RaiseError=>1}) || die "connect error";


my $sth = $dbh->prepare("INSERT INTO 
    user(id, name, sex, birth)
    values
    (?,?,?,?)");
$sth->execute(undef, $name, $sex, $birth) 
          or die $DBI::errstr;
$sth->finish();
$dbh->commit or die $!;


print 
$q->header(-charset=>"utf-8"),
$q->start_html("adduser success"),
$q->p("$name"),
$q->end_html;
