#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: pvAnalyze.pl
#
#        USAGE: ./pvAnalyze.pl  
#
#  DESCRIPTION: report nginx and tomcat log info every day.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 07/16/2015 10:12:13 AM
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
use Getopt::Long;


#===  FUNCTION  ================================================================
#         NAME: getTomcatPng
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getTomcatPng {
    `/opt/mmSdk/bin/tomcatPVAnalyze.pl`;
    `/opt/mmSdk/bin/tomcatHistoryAnalyze.pl`;
    `/opt/mmSdk/bin/tomcatSizeAnalyze.pl`;
    `/opt/mmSdk/bin/tomcat200.pl`;
    `/opt/mmSdk/bin/tomcat400.pl`;
    `/opt/mmSdk/bin/tomcat500.pl`;
    `/opt/mmSdk/bin/tomcatRespTime.pl`;
    `/opt/mmSdk/bin/tomcatMethod.pl`;
    `/opt/mmSdk/bin/tomcatMethodSmall.pl`;
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
    my $testTrigger;
    GetOptions(
        't!' => \$testTrigger,
    );
    my $password = new GetPass;
    $subject = "mmSdk pv analyze";
    my ( $smtpUser, $smtpPass, $smtpFrom, $smtpHost ) =
    $password->getSmtpAuth("username", "password", "from", "host");
    my $logRec;
    if ( $testTrigger ) {
        $logRec = $password->getInfoRec("address");
    }
    else {
        $logRec = $password->getLogRec("address");
    }
    my $fromAddress = $password->getLogRec("from");
    #
    my @PicArray = (
        "tomcatHistory.png",
        "tomcatPV.png",
        "tomcatLogSize.png", 
        "tomcat200.png",
        "tomcat400.png",
        "tomcat500.png",
        "tomcat-resp.png",
        "tomcatMethod.png",
        "tomcatMethodSmall.png",
        "nginxPVToday_full.png",
        "nginxPVPerServerToday_full.png",
    );
    #
    # Send HTML document with inline images
    # Create a new MIME Lite object
    my $msg = MIME::Lite->new(
        From    => $fromAddress,
        To      => $logRec,
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
    $mailer->to(@{$logRec});
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
