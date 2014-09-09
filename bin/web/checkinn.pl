#!/usr/bin/perl
#===============================================================================
#
#         FILE: testget.pl
#
#        USAGE: ./testget.pl  
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
#      CREATED: 10/18/2013 02:33:53 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use CGI ;
use DBI;
use CGI::Carp qw/fatalsToBrowser/;
#use utf8 ;

my $cgi = new CGI ;
print $cgi->redirect("./checkinnform.pl") unless my $name = $cgi->param("name");
print $cgi->header(-charset=>"utf-8");
print $cgi->start_html("thanks for using inncheck");
my ( $dsn , $user, $password )= ("dbi:mysql:test", "kk", "kk") ;
my $dbh = DBI->connect($dsn, $user, $password, ) || die "connect error";
my @queryAOA = ([ "Name", "姓名" ], [ "CtfId" , "身份证号码" ],
    [ "Address" , "地址" ] , [ "Mobile" , "电话" ] );
my $sqlInter = join", ",map{$_->[0]}@queryAOA ;
my $sql = "SELECT ".$sqlInter." From inn WHERE Name = ?";
my $sth = $dbh->prepare($sql);
$sth->execute( "$name" ) or die $DBI::errstr;
my $ref = $sth->fetchall_arrayref() ;
print $cgi->table(
   $cgi->Tr( map{$cgi->th($_)}(map{$_->[1]}@queryAOA) ),
   map{$cgi->Tr(map{$cgi->td($_)}@$_)}@$ref
);
    

print $cgi->end_html;

