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

my $expire_alarm_day = 30;
my @servers = (
    "xxx.com",
);
my $now = time;



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



sub getSSLExpireDay(){
    my $server = shift;
    my $command = "/usr/bin/curl -connect-timeout 10 -m 20 -skv https://$server/ 2>&1"; 
    my $curlResult = `$command`;
    if ( $curlResult =~ /expire\s+date:\s*(.*)/i ) {
        return $1;
    }
    else {
        exec "echo $server SSL info error";
    }
};


sub checkSSL(){
    my $server = shift;
    my $last_expire =  &getSSLExpireDay($server);
    if ( $last_expire ) {
        $last_expire = str2time $last_expire;
        my $timeFormat = strftime "%F",  localtime($last_expire);
        #
        # print out result.
        say "$server $timeFormat" if $opt_t;
        if ( $last_expire - $now < $expire_alarm_day*24*60*60 ) {
            # say "$server expire date is $timeFormat , please check it.";
            say "程序判断 https://$server/ SSL的CA到期时间为 $timeFormat, 请复查。";
        }
    }
}


if ( $opt_h ) {
    usage;
    exit 23;
}

foreach my $server ( @servers ) {
    &checkSSL($server);
}
