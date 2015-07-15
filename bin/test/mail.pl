#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
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
#      CREATED: 07/08/2015 03:29:03 PM
#     REVISION: ---
#===============================================================================

use warnings;
use utf8;
use feature 'say';

use strict;
use MIME::Lite;
use Net::SMTP;
use lib '/tmp';
use GetPass;

sub sendEmailBySmtp {

    my $password = new GetPass;
    my ( $smtpUser, $smtpPass, $smtpFrom, $smtpHost ) =
    $password->getSmtpAuth("username", "password", "from", "host");
    my $infoRec = $password->getLogRec("address");

    # Send HTML document with inline images
    # Create a new MIME Lite object

    my $msg = MIME::Lite->new(
        From    => $smtpFrom,
        To      => $infoRec,
        Subject =>"subjectHere",
        Type    =>'multipart/related');

    # Add the body to your HTML message
    $msg->attach(Type => 'text/html',
        Data => qq{ <BODY BGCOLOR=#FFFFFF>
        <H2>Hi</H2>
        <P ALIGN="left">
        这里应该填写信息一
        </P>
        <P ALIGN="left">
        用于测试邮件显示图片的perl脚本。
        </P>
        </BODY> });

    # Attach the image

    # Send it 
    my $mailer = Net::SMTP->new( $smtpHost );
    $mailer->auth($smtpUser,$smtpPass);
    $mailer->mail($smtpFrom);
    $mailer->to(@{$infoRec});
    $mailer->data;

    # this is where you send the MIME::Lite object
    $mailer->datasend(  $msg->as_string  );
    $mailer->dataend;
    $mailer->quit;
}

&sendEmailBySmtp;
