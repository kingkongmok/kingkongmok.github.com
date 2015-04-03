#!/usr/bin/perl
#===============================================================================
#
#         FILE: dbitest.pl
#
#        USAGE: ./dbitest.pl  
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
#      CREATED: 02/17/2014 02:41:37 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use DBI;
my $dsn = "dbi:mysql:test" ;
my $user = "kk" ;
my $password = "kk" ;
sub query {
    my ($dbh, $name ) = @_ ;
    my $sth = $dbh->prepare("SELECT id, name,
                sex, birth FROM user WHERE name like ?");
    $sth->execute( "%$name%" ) or die $DBI::errstr;
    print "Number of rows found :" , $sth->rows, "\n";
    while (my @row = $sth->fetchrow_array()) {
       my ($id, $name, $age, $birth ) = @row;
       print "id : $id, name: $name \n";
    }
    $sth->finish(); 
} ## --- end sub query


my $dbh = connectDBI($dsn, $user, $password);
#query($dbh, "name");
#insert($dbh, "name2", "f", "1921-1-2");
#query($dbh, "name");
#&delete($dbh, "name2");
#query($dbh, "name");
#update($dbh, 13, "name2", "f", "1921-1-3");
#query($dbh, "name");
#-------------------------------------------------------------------------------
#  check foreach (@{$sth->{NAME}}) http://www.easysoft.com/developer/languages/perl/tutorial_data_web.html
#-------------------------------------------------------------------------------

sub arrayfromquery {
    my ($dbh, $name ) = @_ ;
    my $sth = $dbh->prepare("SELECT id, name,
                sex, birth FROM user WHERE name like ?");
    $sth->execute( "%$name%" ) or die $DBI::errstr;
    foreach (@{$sth->{NAME}}) {
            my %rowh;
            $rowh{HEADING} = $_;
            push @headings, \%rowh;
}
    $sth->finish(); 
} ## --- end sub query




$dbh->disconnect() ;


sub update {
    my $dbh = shift ;
    my ($id, $name, $sex, $birth) = @_;
    my $sth = $dbh->prepare("UPDATE user
                            SET name = ?, sex = ?,
                            birth = ? 
                            WHERE id = ?");
    $sth->execute($name, $sex, $birth, $id) or die $DBI::errstr;
    print "Number of rows updated :", $sth->rows, "\n";
    $sth->finish();
    $dbh->commit or die $DBI::errstr;

} ## --- end sub update

sub delete {
    my $dbh = shift ;
    my ($name) = @_;
    my $sth = $dbh->prepare("DELETE FROM user
                            WHERE name = ?");
    $sth->execute( $name ) or die $DBI::errstr;
    print "Number of rows deleted :" , $sth->rows, "\n";
    $sth->finish();
    $dbh->commit or die $DBI::errstr;
} ## --- end sub delete

sub insert {
    my $dbh = shift ;
    my ($name, $sex, $birth) = @_;
    my $sth = $dbh->prepare("INSERT INTO 
        user(id, name, sex, birth)
        values
        (?,?,?,?)");
    $sth->execute(undef, $name, $sex, $birth) 
              or die $DBI::errstr;
    $sth->finish();
    $dbh->commit or die $!;
} ## --- end sub insert

sub query {
    my ($dbh, $name ) = @_ ;
    my $sth = $dbh->prepare("SELECT id, name,
                sex, birth FROM user WHERE name like ?");
    $sth->execute( "%$name%" ) or die $DBI::errstr;
    print "Number of rows found :" , $sth->rows, "\n";
    while (my @row = $sth->fetchrow_array()) {
       my ($id, $name, $age, $birth ) = @row;
       print "id : $id, name: $name \n";
    }
    $sth->finish(); 
} ## --- end sub query

sub connectDBI {
    my	( $dsn, $sqluser, $sqlpassword )	= @_;
    my $dbh = DBI->connect($dsn, $user, $password,  {AutoCommit=>0, RaiseError=>1}) || die "connect error";
    return $dbh;
} ## --- end sub connectDBI

