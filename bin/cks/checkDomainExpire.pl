#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: checkDomainExpire.pl
#
#        USAGE: ./checkDomainExpire.pl  
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
#      CREATED: 08/15/2016 03:24:41 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
# use utf8;
use Data::Dumper;
use feature 'say';

use Date::Parse;
use Net::Domain::ExpireDate;
use Net::Whois::Raw;
use POSIX "strftime";

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

my @cn_servers = (
    "hangyun.com.cn"
);


foreach my $cn_server ( @cn_servers ) {
    my $s = whois("$cn_server"); 
    if ( $s =~ /exp.*?:(.*)/mi ){
        my $expiration_str = $1 ;
        my $time = str2time $expiration_str;
        if ( $time ) {
            my $timeFormat = strftime "%F",  localtime($time);
            #
            # print out result.
            say "$cn_server $timeFormat" if $opt_t;
            if ( $time - $now < $expire_alarm_day*24*60*60 ) {
                say "$cn_server expire date is $timeFormat , please check it.";
            }
        }
        else {
            my $expiration_str_auto  = expire_date( $_, '%Y-%m-%d' );
            if ( $expiration_str_auto ) {
                my $time = str2time $expiration_str_auto;
                if ( $time - $now < $expire_alarm_day*24*60*60 ) {
                    say "$_ expire date is $expiration_str_auto, please check it.";
                }
            }
        }
    }
    else {
        my $expiration_str_auto  = expire_date( $_, '%Y-%m-%d' );
        if ( $expiration_str_auto ) {
            my $time = str2time $expiration_str_auto;
            if ( $time - $now < $expire_alarm_day*24*60*60 ) {
                say "$_ expire date is $expiration_str_auto, please check it.";
            }
        }
    }
    sleep 10;
}



my @server = (
    "ytmacau.com",
    "cksp.com.hk",
    "zqnewport.com",
    "cksd.com",
    "ckt.com.hk",
    "cks.com.hk",
    "chukong.com",
);

if ( $opt_h)
{
    &usage;
    exit;
}

foreach ( @server ) {
    my $expiration_str  = expire_date( $_, '%Y-%m-%d' );
    #
    # print out the result
    say "$_  $expiration_str" if $opt_t;
    if ( $expiration_str ) {
        my $time = str2time $expiration_str;
        if ( $time - $now < 30*24*60*60 ) {
            say "程序判断 $_ 域名到期时间为 $expiration_str, 请复查。";
        }
    }
    sleep 10;
}
