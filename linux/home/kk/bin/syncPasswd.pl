#!/usr/bin/perl
#===============================================================================
#
#         FILE: syncPasswd.pl
#
#        USAGE: ./syncPasswd.pl  
#
#  DESCRIPTION: sync passwd with gpg and dropbox.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 07/22/2014 10:12:18 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use lib '/home/kk/workspace/perl';
use File::Temp qw/ tempfile tempdir /;
#use KK::Password ;

my ($fh_data, $filename_data) = tempfile();

my $pwsafeDate = '/home/kk/.pwsafe.dat';
my $pwsafeDropbox_descryp='/home/kk/Dropbox/home/kk/.pwsafe.dat.asc' ;

open FH_pwsEncrypted, "<", $pwsafeDropbox_descryp || die $!;
my @string = readline(FH_pwsEncrypted) ;
close FH_pwsEncrypted ;

open FH_tmp, ">", $filename_data || die $! ; 
binmode FH_tmp ;
print FH_tmp &gpgDecrypt(\@string);
close FH_tmp  ;



#-------------------------------------------------------------------------------
#  can't merge db without interactive
#-------------------------------------------------------------------------------
#my %pws_password = &getpassword;
#system("echo $pws_password{kk}{password} | /usr/bin/pwsafe --mergedb=$filename_data"); 
system("/usr/bin/pwsafe --mergedb=$filename_data"); 
unlink $filename_data ;

open FH_pws , "<",  $pwsafeDate || die $!;
my @pwslines = readline(FH_pws);
my $encrypdtxt  =  &gpgEncrypt(\@pwslines);

open FH_pwsEncrypted, ">",  $pwsafeDropbox_descryp || die $! ;
print FH_pwsEncrypted $encrypdtxt ;
close FH_pwsEncrypted ;


sub gpgDecrypt {
    my ($encrypted) = @_ ;
    use Crypt::GPG;
    my $gpg = new Crypt::GPG;
    $gpg->gpgbin('/usr/bin/gpg');      
    $gpg->secretkey('ayanami_0@163.com');     
    my ($plaintext) = $gpg->verify($encrypted);
    return $plaintext ;
} ## --- end sub gpgfile

sub gpgEncrypt {
    my ( $plaintext ) = @_ ;
    use Crypt::GPG;
    my $gpg = new Crypt::GPG;
    $gpg->gpgbin('/usr/bin/gpg');    
    $gpg->secretkey('ayanami_0@163.com');     
    my $encrypted = $gpg->encrypt($plaintext, 'ayanami_0@163.com') || die $! ;
} ## --- end sub gpgfile

