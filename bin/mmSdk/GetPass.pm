#
#===============================================================================
#
#         FILE: GetPass.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 07/09/2015 09:17:05 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package GetPass;


sub new {
    return bless {}, shift ;
}

my %infoRec = (
    address => '邮箱接受的地址： foo@bar.com',
    from => '需要伪装的邮件From地址: fake@bar.com',
);


# for daily log
my %logRec = (
    address => 'kingkongmok@gmail.com moqingqiang@richinfo.cn',
    from => 'sys.report@139.com',
);

my %smtpAuth = (
    username => 'smtp的账号',
    password => 'smtp的密码',
    from => 'smtp的from， foo@bar.com',
    host => 'smtp的地址： smtp.host.com',
);

sub getInfoRec {
    shift;
    my @param = @_;
    return @infoRec{@param};
}

sub getLogRec {
    shift;
    my @param = @_;
    return @logRec{@param};
}

sub getSmtpAuth {
    shift;
    my @param = @_;
    return @smtpAuth{@param};
}

1

