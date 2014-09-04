#!/usr/bin/perl
#===============================================================================
#
#         FILE: cgi_create.pl
#
#        USAGE: ./cgi_create.pl  
#
#  DESCRIPTION: test create from DBI::MYSQL
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/17/2014 02:37:16 PM
#     REVISION: ---
#===============================================================================

#use strict;
#use warnings;

use CGI ;
use DBI;
use CGI::Carp qw/fatalsToBrowser/;
#use utf8 ;
use Data::Dumper ;

my $cgi = new CGI ;

if ( $cgi->param("Name") ) {
    my %vars = $cgi->Vars ;
    &dbi_create(\%vars) ;
}
else {
    &print_create_form ;
}



sub print_create_form {
    print $cgi->header(-charset=>"utf-8"),
    $cgi->start_html("create page testing"),
    $cgi->start_form(
        -action=>"checkinn.pl",
        -name=>"submit",
    ),
    $cgi->p("username"), $cgi->input({-name=>"username",-value=>$default_user_name}),
    $cgi->p("password"), $cgi->input({-name=>"password",-value=>$default_user_name}),
    $cgi->submit(-value=>"给我查！");
    $cgi->end_form,
    $cgi->end_html(),
} ## --- end sub print_create_form

sub dbi_create {
    my %vars = %{shift()} ;
    use Data::Dumper;
    print $cgi->header, Dumper(\%vars);

    print my ( $Name, $CtfId, $Address, $Mobile) = ($vars{Name}, $vars{CtfId}, $vars{Address}, $vars{Mobile}) ;
#    print $cgi->header(-charset=>"utf-8");
#    print $cgi->start_html("thanks for using inncheck");
    my ( $dsn , $user, $password )= ("dbi:mysql:test", "kk", "kk") ;
    my $dbh = DBI->connect($dsn, $user, $password, ) || die "connect error";
    my @queryAOA = ([ "Name", "姓名" ], [ "CtfId" , "身份证号码" ],
        [ "Address" , "地址" ] , [ "Mobile" , "电话" ] );
    my $sqlInter = join", ",map{$_->[0]}@queryAOA ;
    #my $sql = "SELECT ".$sqlInter." From inn WHERE Name = ?";
    my $sql = "INSERT ".$sqlInter." INTO inn VALUES()";
#    my $sth = $dbh->prepare($sql);
#    $sth->execute( "$name" ) or die $DBI::errstr;
#    my $ref = $sth->fetchall_arrayref() ;
#    print $cgi->table(
#       $cgi->Tr( map{$cgi->th($_)}(map{$_->[1]}@queryAOA) ),
#       map{$cgi->Tr(map{$cgi->td($_)}@$_)}@$ref
#    );
#    print $cgi->end_html;
#        my	( $par1 )	= @_;
#        return ;

} ## --- end sub dbi_create
