#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: checkRouteStatusHourly.pl
#
#        USAGE: ./checkRouteStatusHourly.pl
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/10/2015 09:39:23 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Getopt::Long;
use MIME::Lite;
use Net::SMTP;
use FindBin;
use lib "$FindBin::Bin";;
use GetPass;
use Getopt::Long;
use File::Temp "tempfile";
use File::Basename;

#===  FUNCTION  ================================================================
#         NAME: writeMail
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub writeMail {
    my $fh_tmp = shift;
    my @files = glob("/home/logs/*_mmlogs/crontabLog/checkRouter.log");
    my %ip_file = ( 
        "/home/logs/1_mmlogs/crontabLog/checkRouter.log" => "192.168.42.1",
        "/home/logs/4_mmlogs/crontabLog/checkRouter.log" => "192.168.42.2",
        "/home/logs/3_mmlogs/crontabLog/checkRouter.log" => "192.168.42.3",
        "/home/logs/5_mmlogs/crontabLog/checkRouter.log" => "192.168.42.5",
    ); 
    my ($dirname, $filename, $tmpfile) = ($1,$3,"/tmp/$3-$$.tmp") if $0 =~
    m/^(.*)(\\|\/)(.*)\.([0-9a-z]*)/;
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
    my $testTrigger;
    GetOptions(
        't!' => \$testTrigger,
    );
    # prod: check 1 hour ago.
    # test: check this hour.
    chomp (my $timestamp = $testTrigger ? 
        sprintf "%d-%02d-%02d %02d\n", $year+1900, $mon+1, $mday, $hour-5
        :
        sprintf "%d-%02d-%02d %02d\n", $year+1900, $mon+1, $mday, $hour-1
    );
    #
    my $mailSubj;
    my $mailMessage = "router errors may occured at: "; 
    foreach my $file ( @files ) {
        open my $fh , "< $file" || die $!;
        while ( <$fh> ) {
            if ( /$timestamp/..eof ) {
                s/<.*?>//g;
                print $fh_tmp $_;
                $mailMessage .= $1 . ", " if /tracing route start at .* (\d+:\d+):\d+$/;
            }
            if ( /tracing route start at ($timestamp.*)/ ) {
                chomp;
                $mailSubj //= "route error at $ip_file{$file} $1";
            }
        }
        close $fh; 
    }
    return ($mailSubj, join ", ",$mailMessage);
} ## --- end sub writeMail


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
    my ($subject, $message, $filename_tmp) = @_;
    my $password = new GetPass;
    $subject =~ s/_$//;
    my ( $smtpUser, $smtpPass, $smtpFrom, $smtpHost ) =
    $password->getSmtpAuth("username", "password", "from", "host");
    my $infoRec = $password->getInfoRec("address");
    my $fromAddress = $password->getInfoRec("from");
    my @PicArray = (
        "nginxPVHourly.png",
        "nginxPVToday.png",
        "nginxPVPerServerHourly.png",
        "nginxPVPerServerToday.png",
    );
    # Send HTML document with inline images
    # Create a new MIME Lite object
    my $msg = MIME::Lite->new(
        From    => $fromAddress,
        To      => $infoRec,
        Subject => $subject,
        Type    =>'multipart/related');
    # Add the body to your HTML message
    #
    # 
    my @htmlScriptArray = @PicArray;
    map { s/$_/<IMG SRC="cid:$_">/g; $_} @htmlScriptArray;
    my $htmlPicScript = join "", @htmlScriptArray;
    #
    $msg->attach(Type => 'text/html',
        Data => qq{ 
        <BODY>
        <P ALIGN="left">
        $message 
        </P>
        $htmlPicScript
        </BODY> });
    # txt file here.
    $msg->attach(
        Type => 'x-gzip', 
        Path => "gzip < $filename_tmp |",
        Filename => "erro_log.txt.gz"
   );
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


my ($basename) = fileparse($0, ".pl");
my($fh_tmp,$filename_tmp) = tempfile("/tmp/$basename-$$-XXXX", "UNLINK", 1);

my ($mailSubj, $mailMessage) = &writeMail($fh_tmp);
if ( $mailSubj ) {
    system("$FindBin::Bin/nginxPvCheck.pl -p");
    &sendEmailBySmtp($mailSubj, $mailMessage, $filename_tmp);
}
