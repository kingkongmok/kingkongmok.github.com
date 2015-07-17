#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: nginxPvCheck.pl
#
#        USAGE: "./nginxPvCheck.pl" for cronie, "./nginxPvCheck.pl 0" for
#               testing 
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
#      CREATED: 06/08/2015 11:08:20 AM
#     REVISION: ---
#===============================================================================

$ENV{GDFONTPATH}= "/usr/share/fonts/liberation";
$ENV{GNUPLOT_DEFAULT_GDFONT}= "LiberationSans-Regular";

use strict;
use warnings;
use utf8;
use feature 'say';
use Fcntl 'O_RDONLY';
use Tie::File;
use Statistics::Descriptive;
use Storable qw(retrieve);
use Data::Dumper;
use Chart::Gnuplot;
use POSIX 'strftime';
use Getopt::Long;
use MIME::Lite;
use Net::SMTP;
use FindBin;
use lib "$FindBin::Bin";;
use GetPass;


#-------------------------------------------------------------------------------
#  settings
#-------------------------------------------------------------------------------
# check the 60 minutes ( 1hour ) history from nginx_status.log.
my $line_number = 60;   # hourly
# nginx status.log location
my @logLocations = (
    "/home/logs/1_mmlogs/crontabLog/nginx/",
    "/home/logs/4_mmlogs/crontabLog/nginx/",
    "/home/logs/3_mmlogs/crontabLog/nginx/",
    "/home/logs/5_mmlogs/crontabLog/nginx/",
);
my %lognameServerMap = (
    "/home/logs/1_mmlogs/crontabLog/nginx/nginx_status.log" => "42.1",
    "/home/logs/4_mmlogs/crontabLog/nginx/nginx_status.log" => "42.2",
    "/home/logs/3_mmlogs/crontabLog/nginx/nginx_status.log" => "42.3",
    "/home/logs/5_mmlogs/crontabLog/nginx/nginx_status.log" => "42.5",
);
my $logfilename = "nginx_status.log";
my $hashHistoryFile = "/tmp/nginxHistoryPV_backup.hash";


#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------

my $thisDate = strftime "%F", localtime time;
my $getPicOnlyTrigger = 0;
my $testTrigger = 0;
my $nightTrigger = 0;
GetOptions(
    'p!' => \$getPicOnlyTrigger,
    't!' => \$testTrigger,
    'n!' => \$nightTrigger,
);
# compare with history ( $nowValue - $history->mean() ) / $history->mean 
my $threshold = $testTrigger ? 0 : $nightTrigger ? 0.35 : 0.25;
# threshold of RSD now value;
my $RSDthreshold = $testTrigger ? 0 : $nightTrigger ? 16 : 13;

#===  FUNCTION  ================================================================
#         NAME: getRequestsToday
#      PURPOSE: get today's handling requests by analyzing nginx_status.log with
#               Tie::File
#   PARAMETERS: @logs filename
#      RETURNS: %requestsMinutely = { 
#                   '14:09' => 951776,
#               }
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getRequestsToday {
    my ($logFilesRef, $lognameServerMapRef) = @_;
    my	@logFiles	= @{$logFilesRef};
    my %lognameServerMap = %{$lognameServerMapRef};
    my %requestsToday;
    my %requestsPerServer;
    my @hourlyLines;
    foreach my $filename ( @logFiles ) {
        tie my @lines, 'Tie::File', $filename, mode => "O_RDONLY" || die $!;
        my @specifyLines = grep {/^Active connections:.*Waiting/} @lines;
        for ( my $i=1; $i<~~@specifyLines; $i++ ) {
            #$requestsToday{ substr $specifyLines[$i], -8, 5 } += 
            my $requestThistMinute =  
            +(split/\s+/, $specifyLines[$i])[9] > +(split/\s+/,
                $specifyLines[$i-1])[9] ? +(split/\s+/,
                $specifyLines[$i])[9] - +(split/\s+/,
                $specifyLines[$i-1])[9] : +(split/\s+/,
                $specifyLines[$i])[9];
            $requestsToday{ substr $specifyLines[$i], -8, 5 } +=
            $requestThistMinute;
            $requestsPerServer{ $lognameServerMap{$filename} }{substr
            $specifyLines[$i], -8, 5 } =  $requestThistMinute;
        }
        untie @lines;
    }
    return (\%requestsToday, \%requestsPerServer);
} ## --- end sub getRequestsToday


#===  FUNCTION  ================================================================
#         NAME: getRequestsMinutely
#      PURPOSE: get every minute handling requests by analyzing
#               nginx_status.log with Tie::File
#   PARAMETERS: @logs filename
#      RETURNS: %requestsMinutely = {
#                   '14:09' => 951776,
#               }
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getRequestsMinutely (@) {
    my	@logFiles	= @_;
    my %requestsMinutely;
    my @hourlyLines;
    foreach my $filename ( @logFiles ) {
        tie my @lines, 'Tie::File', $filename, mode => "O_RDONLY" || die $!;
        # 
        # startLine numb and endLineNumb should both -1 incase of losting nginx
        # status
        #
        my $startLineNumb = $#lines - 1 > $line_number ? 
        $#lines - 1 - $line_number : 0;
        my @specifyLines = @lines[ $startLineNumb .. ( $#lines -1 ) ];
        #
        for ( my $i=1; $i<~~@specifyLines; $i++ ) {
            $requestsMinutely{ substr $specifyLines[$i], -8, 5 } += 
            +(split/\s+/, $specifyLines[$i])[9] > +(split/\s+/,
                $specifyLines[$i-1])[9] ? +(split/\s+/,
                $specifyLines[$i])[9] - +(split/\s+/,
                $specifyLines[$i-1])[9] : +(split/\s+/,
                $specifyLines[$i])[9];
        }
        untie @lines;
    }
    return \%requestsMinutely;
} ## --- end sub getRequestsMinutely


#===  FUNCTION  ================================================================
#         NAME: getStatistics
#      PURPOSE: get sum, mean, max, maxdex, min, mindex, RSD by
#               Statistics::Descriptive::Full
#   PARAMETERS: @pv = ( 111, 100, 120 , .. )
#      RETURNS: %hash = ( 
#                     sum => 111.25,
#                     RSD => "2.3%",
#                 )
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getStatistics {
    my $requestValue = shift;
    my $stat = Statistics::Descriptive::Full->new();
    $stat->add_data( $requestValue );
    my %hash;
    my $standard_deviation=$stat->standard_deviation();
    $hash{sum} = $stat->sum();
    $hash{mean} = $stat->mean();
    $hash{max} = $stat->max();
    $hash{maxdex} = $stat->maxdex();
    $hash{min} = $stat->min();
    $hash{mindex} = $stat->mindex();
    $hash{RSD}=$standard_deviation/$hash{mean} * 100;
    return (\%hash);
} ## --- end sub getStatistics


#===  FUNCTION  ================================================================
#         NAME: getStatusDetail
#      PURPOSE: compare 
#   PARAMETERS: $requestsNowHashRef, $requestHistoryHashRef
#      RETURNS: alarm if 100*(now->sample - history->mean)/history->mean  
#  DESCRIPTION: pack lasthour data and history data, analyze with
#               $::getStatistics
#     COMMENTS: none
#     SEE ALSO: n/a
#==============================================================================
sub getStatusDetail {
    my	( $requestsNowHashRef, $requestHistoryHashRef)	= @_;
    #
    # pack history data 
    my ( @hist_sum, @hist_mean, @hist_RSD, @hist_max, @hist_min, @hist_maxdex,
        @hist_mindex);
    for my $date (sort keys%{$requestHistoryHashRef}) {
        my @pv;
        for my $time (sort keys %{$requestsNowHashRef}) {
            if ( $requestHistoryHashRef->{$date}{$time} ) {
                push @pv,$requestHistoryHashRef->{$date}{$time};
            }
        }
        if ( @pv ) {
            my %hist_hash  = %{getStatistics(\@pv)} if @pv;
            push @hist_sum, $hist_hash{sum};
            push @hist_mean,$hist_hash{mean};
            push @hist_max, $hist_hash{max};
            push @hist_maxdex, $hist_hash{maxdex};
            push @hist_min, $hist_hash{min};
            push @hist_mindex, $hist_hash{mindex};
            push @hist_RSD, $hist_hash{RSD};
        }
    }
    my %hist_Array_hash = (
        sum => [ @hist_sum ] ,
        mean => [ @hist_mean ] ,
        max => [ @hist_max ] ,
        maxdex => [ @hist_maxdex ] ,
        min => [ @hist_min ] ,
        mindex => [ @hist_mindex ] ,
        RSD => [ @hist_RSD ] ,
    );
    #
    # pack today data 
    my @pv = @{$requestsNowHashRef}{sort keys %{$requestsNowHashRef}};
    my %now_hash = %{getStatistics(\@pv)} if @pv;
    #
    return ( \%hist_Array_hash, \%now_hash);
} ## --- end sub getStatusDetail


#===  FUNCTION  ================================================================
#         NAME: drawPicPerServer
#      PURPOSE: drawpic with Chart::Gnuplot, plot EVERY SERVER's requests
#   PARAMETERS: ????
#      RETURNS: plot2d return
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub drawPicPerServer {
    my ($requestsNowHashRef, $requestsPerServer, $outputname, $thisDate) = @_;
    my @x = sort keys %{$requestsNowHashRef};
    my %timeReq;
    #
    # insert every server's data
    foreach my $server ( sort keys %{$requestsPerServer}  ) {
        foreach my $time ( sort keys %{$requestsNowHashRef} ) {
            $timeReq{$server}{$time} = $requestsPerServer->{$server}{$time} ?
            $requestsPerServer->{$server}{$time}/10_000 : 0;
        }
    }
    #
    my @dates_toDraw = sort keys  %timeReq;
    # set plot format.
    my $chart = Chart::Gnuplot->new(
        output => "/tmp/$outputname.png",
        terminal => 'png',
        imagesize => "1000,500", 
        key => 'top left',
        title => {
            text => "all servers' $thisDate nginx requests",
            font => "LiberationMono-Regular, 20",
        },
        grid => 'on',
        timeaxis => "x",
        xlabel => 'Time: every minute',
        ylabel => 'request(10K)',
    );
    # #
    my @dataSetArray;
    for ( my $iterator=0; $iterator<$#dates_toDraw+1; $iterator++ ) {
        $dataSetArray[$iterator] = Chart::Gnuplot::DataSet->new(
            xdata   => \@x,
            ydata   => [@{$timeReq{$dates_toDraw[$iterator]}}{sort keys
                %{$timeReq{$dates_toDraw[$iterator]}}}],
            style   => 'lines',
            title => "$dates_toDraw[$iterator]",
            timefmt => '%H:%M',      # input time format
        );
    }
    $chart->plot2d(@dataSetArray);
} ## --- end sub drawPicrequestHistoryHashRefPerServer


#===  FUNCTION  ================================================================
#         NAME: drawPic
#      PURPOSE: drawpic with Chart::Gnuplot, plot lasthour pv and today's pv. 
#   PARAMETERS: ????
#      RETURNS: plot2d return
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub drawPic {
    my ($requestsNowHashRef, $requestHistoryHashRef, $outputname, $thisDate) =
    @_;
    my @x = sort keys %{$requestsNowHashRef};
    my %timeReq;
    #
    # insert today's data
    foreach my $time ( sort keys %{$requestsNowHashRef} ) {
        $timeReq{today}{$time} = $requestsNowHashRef->{$time} ?
        $requestsNowHashRef->{$time}/10_000 : 0;
    }
    #
    # insert history data
    foreach my $day ( sort keys %{$requestHistoryHashRef} ) {
        foreach my $time ( sort keys %{$requestsNowHashRef}) {
            $timeReq{$day}{$time} = $requestHistoryHashRef->{$day}{$time} ?
            $requestHistoryHashRef->{$day}{$time}/10_000 : 0;
        }
    }
    #
    my @dates_toDraw = sort keys  %timeReq;
    # set plot format.
    my $chart = Chart::Gnuplot->new(
        output => "/tmp/$outputname.png",
        terminal => 'png',
        imagesize => "1000,500", 
        key => 'top left',
        title => {
            text => "all servers' $thisDate nginx requests",
            font => "LiberationMono-Regular, 20",
        },
        grid => 'on',
        timeaxis => "x",
        xlabel => 'Time: every minute',
        ylabel => 'request(10K)',
    );
    #
    # draw today
    my $dataset = Chart::Gnuplot::DataSet->new(
        xdata   => \@x,
        ydata   => [@{$timeReq{$dates_toDraw[-1]}}{sort keys
            %{$timeReq{$dates_toDraw[-1]}}}],
        style   => 'lines',
        width => 3,
        color => "green",
        title => $dates_toDraw[-1],
        timefmt => '%H:%M',      # input time format
    );
    #
    # draw history
    my @dataSetArray;
    for ( my $iterator=0; $iterator<$#dates_toDraw; $iterator++ ) {
        $dataSetArray[$iterator] = Chart::Gnuplot::DataSet->new(
            xdata   => \@x,
            ydata   => [@{$timeReq{$dates_toDraw[$iterator]}}{sort keys
                %{$timeReq{$dates_toDraw[$iterator]}}}],
            style   => 'lines',
            title => "$dates_toDraw[$iterator]",
            timefmt => '%H:%M',      # input time format
        );
    }
    $chart->plot2d($dataset, @dataSetArray);
} ## --- end sub drawPic


#-------------------------------------------------------------------------------
#  假设检验
#-------------------------------------------------------------------------------
sub outlier_filter { return $_[1] > 0.1; } 


#===  FUNCTION  ================================================================
#         NAME: getComparation
#      PURPOSE: compare with last minute and history, 
#   PARAMETERS: ????
#      RETURNS: $comparation, $filtered_index,
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: $comparation = ($lastHourValue -
#               $historyArray->mean)/$historyArray->mean 
#     SEE ALSO: n/a
#===============================================================================
sub getComparation {
    my	( $histArrayRef, $nowValue)	= @_;
    my $stat = Statistics::Descriptive::Full->new(); 
    $stat->add_data($histArrayRef);
    $stat->set_outlier_filter( \&outlier_filter ); # 数据标准化排除一个数据 
    my $filtered_index = $stat->_outlier_candidate_index;
    my @filtered_data = $stat->get_data_without_outliers();
    $stat = Statistics::Descriptive::Full->new();
    $stat->add_data(\@filtered_data);
    my $mean=$stat->mean();
    my $Comparation = $mean ? ( $nowValue - $mean ) / $mean : 0;
    return ($Comparation, $filtered_index );
} ## --- end sub getComparation


#===  FUNCTION  ================================================================
#         NAME: getPicOnly
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getPicOnly {
    my ($errorStr, $mailSubj, $requestsNowHashRef, $requestHistoryHashRef,
        $requestsToday, $requestsPerServer, $startTimeEndTime ) = @_;
    drawPic($requestsNowHashRef, $requestHistoryHashRef, "nginxPVHourly",
        $thisDate);
    drawPic($requestsToday, $requestHistoryHashRef, "nginxPVToday",
        $thisDate);
    drawPicPerServer($requestsNowHashRef, $requestsPerServer,
        "nginxPVPerServerHourly", $thisDate);
    drawPicPerServer($requestsToday, $requestsPerServer,
        "nginxPVPerServerToday", $thisDate);
} ## --- end sub getPicOnly


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
    my ($subject, $message) = @_;
    my $password = new GetPass;
    $subject =~ s/^/mmSdk_nginxs_/;
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
        $message
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
#-------------------------------------------------------------------------------
#  get requests result from log files. ( today )
#-------------------------------------------------------------------------------
my @logFiles = map { $_ . $logfilename } @logLocations;
my $requestsNowHashRef = getRequestsMinutely(@logFiles);
my $startTimeEndTime = join"~",+(sort keys %{$requestsNowHashRef})[0,-1];
my ($requestsToday, $requestsPerServer) = getRequestsToday(\@logFiles,
    \%lognameServerMap);
my $requestHistoryHashRef = retrieve("$hashHistoryFile");
my ( $hist_Array_hash, $now_hash ) = getStatusDetail( $requestsNowHashRef,
    $requestHistoryHashRef);
#-------------------------------------------------------------------------------
#  check mean, sum, min, max with history and $threshold, 
#    abs ($comparation) > $threshold ?
#           alarm : next;
#-------------------------------------------------------------------------------
my $errorStr;
my $mailSubj;
#-------------------------------------------------------------------------------
#  get comparation and filtered_index for mean sum min max
#-------------------------------------------------------------------------------
foreach my $statKey ( qw/mean sum min max/ ) {
    my $histdata = $hist_Array_hash->{$statKey};
    my $nowdata = $now_hash->{$statKey};
    my ($comparation, $filtered_index ) = getComparation( \@$histdata,
        $nowdata);
    if ( abs($comparation)>$threshold ) {
        my %hashValue;
        my @hashFiltered;
        my $updown = $comparation > 0 ? "+" : "-";
        $comparation = sprintf "%.2f%%", abs$comparation*100;
        $errorStr //= "<p>some errors may be occured at all_nginx during $startTimeEndTime:</p>"; 
        $errorStr .= sprintf
        "<p><font color='blue'><b>%s %s%s</b></font><br>",$statKey, $updown,
        $comparation;
        $mailSubj .= sprintf "%s%s%s_",$statKey, $updown, $comparation;
        $errorStr .= sprintf
        "<font color='green'><b>today</b></font>: %i<br>",$nowdata;
        @hashValue{sort keys
        %{$requestHistoryHashRef}}=map{s/$_/sprintf"%i",$_/eg; $_}@$histdata;
        $hashFiltered[$filtered_index]=" (filtered)";
        my $iterator = 0;
        foreach ( sort keys %hashValue ) {
            $errorStr .= sprintf "  %5s: %s",$_, $hashValue{$_} || "n/a";
            $errorStr .= $hashFiltered[$iterator] || "";
            $errorStr .= "<br>";
            $iterator++;
        }
        $errorStr .= "</p>\n";
    }
}
#-------------------------------------------------------------------------------
#  get comparation and filtered_index for RSD
#-------------------------------------------------------------------------------
foreach my $statKey ( qw/RSD/ ) {
    my $histdata = $hist_Array_hash->{$statKey};
    my $nowdata = $now_hash->{$statKey};
    my ($comparation, $filtered_index ) = getComparation( \@$histdata,
        $nowdata);
    if ( abs($comparation)>$threshold && $nowdata > $RSDthreshold) {
        my %hashValue;
        my @hashFiltered;
        if ( $comparation > 0 ) {
            my $updown = $comparation > 0 ? "+" : "-";
            $comparation = sprintf "%.2f%%", abs$comparation*100;
            $errorStr //= "<p>some errors may be occured at all_nginx during $startTimeEndTime:</p>"; 
            $errorStr .= sprintf 
            "<p><font color='blue'><b>%s %s%s</b></font><br>",$statKey,
            $updown, $comparation;
            $mailSubj .= sprintf "%s%s%s_",$statKey, $updown, $comparation;
            $errorStr .= sprintf
            "<font color='green'><b>today</b></font>: %.2f%%<br>",$nowdata;
            @hashValue{sort keys
            %{$requestHistoryHashRef}}=map{s/$_/sprintf"%.2f",$_/eg;
            $_}@$histdata;
            $hashFiltered[$filtered_index]=" (filtered)";
            my $iterator = 0;
            foreach ( sort keys %hashValue ) {
                $errorStr .= sprintf "  %5s: %s%%",$_, $hashValue{$_} || "n/a";
                $errorStr .= $hashFiltered[$iterator] || "";
                $errorStr .= "<br>";
                $iterator++;
            }
            $errorStr .= "</p>\n";
        }
    }
}
if ( $mailSubj ) {
    getPicOnly($errorStr, $mailSubj, $requestsNowHashRef,
        $requestHistoryHashRef, $requestsToday, $requestsPerServer,
        $startTimeEndTime); 
    sendEmailBySmtp($mailSubj, $errorStr);
}
if ( $getPicOnlyTrigger ) {
    getPicOnly($errorStr, $mailSubj, $requestsNowHashRef,
        $requestHistoryHashRef, $requestsToday, $requestsPerServer,
        $startTimeEndTime); 
} 
