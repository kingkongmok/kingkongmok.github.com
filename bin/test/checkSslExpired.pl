#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: checkSslExpired.pl
#
#        USAGE: ./checkSslExpired.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 11/27/2017 02:58:06 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
# use utf8;
use Data::Dumper;
use feature 'say';



use Date::Parse;
use POSIX "strftime";
use LWP::UserAgent;

#-------------------------------------------------------------------------------
#  usage
#-------------------------------------------------------------------------------
use Getopt::Std;
getopts('ht');
our($opt_h, $opt_t);

sub usage {
    print <<HELPTEXT;                                                           

    目的： 查域名有效期
    

    参数：
            -t          测试
            -h          print this help                      

HELPTEXT
}



my $expire_alarm_day = 30;

my $now = time;

my @servers = (
    "test2.cks.com.hk",
    "ticketing.cotaiwaterjet.com",
);



my $last_expire;
my $ua = LWP::UserAgent->new(
    ssl_opts => {
        SSL_verify_callback => sub {
            my ($ok, $ctx_store) = @_;
            my $cert = Net::SSLeay::X509_STORE_CTX_get_current_cert($ctx_store);
            $last_expire =
            Net::SSLeay::P_ASN1_TIME_get_isotime(Net::SSLeay::X509_get_notAfter($cert));
            return $ok;
        },
    },
);

foreach my $server ( @servers ) {
    $ua->get("https://$server/");
    if ( $last_expire ) {
        $last_expire = str2time $last_expire;
        my $timeFormat = strftime "%F",  localtime($last_expire);
        #
        # print out result.
        say "$server $timeFormat" if $opt_t;
        #if ( $last_expire - $now < $expire_alarm_day*24*60*60 ) {
        if ( $last_expire - $now < $expire_alarm_day*24*60*60 ) {
            # say "$server expire date is $timeFormat , please check it.";
            say "程序判断 https://$server/ SSL的CA到期时间为 $timeFormat, 请复查。";
        }
    }
}
