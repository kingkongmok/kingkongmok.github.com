#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: mmSdk_Status.pl
#
#        USAGE: ./mmSdk_Status.pl  
#
#  DESCRIPTION: get nginx and tomcat's info
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 07/16/2015 09:59:02 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use feature 'say';
use MIME::Lite;
use Net::SMTP;
use FindBin;
use lib "$FindBin::Bin";;
use GetPass;

#===  FUNCTION  ================================================================
#         NAME: getTomcatPng
#      PURPOSE: run commmands and get pngs.
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getTomcatPng {
    `/opt/mmSdk/bin/tomcat200_now.pl`;
    `/opt/mmSdk/bin/tomcat400_now.pl`;
    `/opt/mmSdk/bin/tomcat500_now.pl`;
    `/opt/mmSdk/bin/tomcatRespTime_now.pl`;
    `/opt/mmSdk/bin/tomcatMethod_now.pl`;
    `/opt/mmSdk/bin/tomcatMethodSmall_now.pl`;
    `/opt/mmSdk/bin/nginxPvCheck.pl -p`;
} ## --- end sub getTomcatPng


#===  FUNCTION  ================================================================
#         NAME: sendEmailBySmtp
#      PURPOSE: write mail with MIME::Lite, and send with Net::SMTP
#   PARAMETERS: $subject, $message
#      RETURNS: ????
#  DESCRIPTION: read GetPass.pm , get smtp auth and recipient. then send mail
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub sendEmailBySmtp {
    my ($subject, $message); 
    my $password = new GetPass;
    $subject = "mmSdk_Status";
    my ( $smtpUser, $smtpPass, $smtpFrom, $smtpHost ) =
    $password->getSmtpAuth("username", "password", "from", "host");
    my $infoRec = $password->getInfoRec("address");
    my $fromAddress = $password->getLogRec("from");
    # 
    my @PicArray = (
        "nginxPVHourly.png", 
        "nginxPVToday.png", 
        "nginxPVPerServerHourly.png",
        "nginxPVPerServerToday.png",
        "tomcat200_now.png",
        "tomcat400_now.png",
        "tomcat500_now.png",
        "tomcat-resp_now.png",
        "tomcatMethod_now.png",
        "tomcatMethodSmall_now.png",
    );
    #
    # Send HTML document with inline images
    # Create a new MIME Lite object
    my $msg = MIME::Lite->new(
        From    => $fromAddress,
        To      => $infoRec,
        Subject => $subject,
        Type    =>'multipart/related');
    # Add the body to your HTML message
    #
    my @htmlScriptArray = @PicArray;
    map { s/$_/<IMG SRC="cid:$_">/g; $_} @htmlScriptArray;
    my $htmlPicScript = join "", @htmlScriptArray;
    #
    $msg->attach(Type => 'text/html',
        Data => qq{ 
        <BODY>
        $htmlPicScript
        </BODY> });
    # Attach the image
    foreach my $picName ( @PicArray ) {
        $msg->attach(Type => 'image/png',
            Id   => "$picName",
            Path => "/tmp/$picName");
    }
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


#-------------------------------------------------------------------------------
#  start here
#-------------------------------------------------------------------------------
&getTomcatPng(); 
&sendEmailBySmtp();
