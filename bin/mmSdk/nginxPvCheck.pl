#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: nginxPvCheck.pl
#
#        USAGE: ./nginxPvCheck.pl  
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


#-------------------------------------------------------------------------------
#  settings
#-------------------------------------------------------------------------------
my $line_number = 60 ;   # hourly
my @logLocations = qw#
    /home/logs/1_mmlogs/crontabLog/nginx/
    /home/logs/4_mmlogs/crontabLog/nginx/
    /home/logs/3_mmlogs/crontabLog/nginx/
    /home/logs/5_mmlogs/crontabLog/nginx/
#;
# my @logLocations = (
#     "/home/kk/Documents/logs/nginx/1/",
#     "/home/kk/Documents/logs/nginx/2/",
#     "/home/kk/Documents/logs/nginx/3/",
#     "/home/kk/Documents/logs/nginx/5/",
# );
my $logfilename = "nginx_status.log";
my $hashHistoryFile = "/tmp/nginxHistoryPV_backup.hash";
my $threshhold = 0.25;


#-------------------------------------------------------------------------------
#  don't edit below
#-------------------------------------------------------------------------------


#===  FUNCTION  ================================================================
#         NAME: getRequestsToday
#      PURPOSE: 
#   PARAMETERS: @logs filename
#      RETURNS: %requestsToday = 
#                   '14:09' => 951776,
#               }
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getRequestsToday (@) {
    my	@logFiles	= @_;
    my %requestsMinutely;
    my @hourlyLines;
    foreach my $filename ( @logFiles ) {
        tie my @lines, 'Tie::File', $filename, mode => "O_RDONLY" || die $!;
        # my $displayLine = $#lines - $line_number > 0 ? $#lines - $line_number : 0 ;
        # my @specifyLines = @lines[ $displayLine ..  $#lines ];
        my @specifyLines = @lines;
        for ( my $i=1; $i<~~@specifyLines; $i++ ) {
            $requestsMinutely{ substr $specifyLines[$i], -8, 5 } += 
            abs(+(split/\s+/, $specifyLines[$i])[9] - +(split/\s+/,
                    $specifyLines[$i-1])[9]);
        }
        untie @lines;
    }
    return \%requestsMinutely;
} ## --- end sub getRequestsToday


#===  FUNCTION  ================================================================
#         NAME: getRequestsMinutely
#      PURPOSE: 
#   PARAMETERS: @logs filename
#      RETURNS: %requestsMinutely = 
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
        my $displayLine = $#lines - $line_number > 0 ? $#lines - $line_number : 0 ;
        my @specifyLines = @lines[ $displayLine ..  $#lines ];
        for ( my $i=1; $i<~~@specifyLines; $i++ ) {
            $requestsMinutely{ substr $specifyLines[$i], -8, 5 } += 
            abs(+(split/\s+/, $specifyLines[$i])[9] - +(split/\s+/,
                    $specifyLines[$i-1])[9]);
        }
        untie @lines;
    }
    return \%requestsMinutely;
} ## --- end sub getRequestsMinutely


#===  FUNCTION  ================================================================
#         NAME: getStatistics
#      PURPOSE: get sum, mean, max, maxdex, min, mindex, RSD
#   PARAMETERS: @pv
#      RETURNS: %hash
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getStatistics {
    my $requestValue = shift;
    my $stat = Statistics::Descriptive::Full->new();
    $stat->add_data( $requestValue );
    my %hash ;
    my $standard_deviation=$stat->standard_deviation();#标准差
    $hash{sum} = $stat->sum();
    $hash{mean} = $stat->mean();#平均值
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
#  DESCRIPTION: compare RSD, mean
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#==============================================================================
sub getStatusDetail {
    my	( $requestsNowHashRef, $requestHistoryHashRef)	= @_;
    #
    # history data below
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
    # today data below
    my @pv = @{$requestsNowHashRef}{sort keys %{$requestsNowHashRef}};
    my %now_hash = %{getStatistics(\@pv)} if @pv;
    #
    return ( \%hist_Array_hash, \%now_hash);
} ## --- end sub getStatusDetail


#===  FUNCTION  ================================================================
#         NAME: drawPic
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub drawPic {
    my ($requestsNowHashRef, $requestHistoryHashRef, $outputname) = @_;
    my @x = sort keys %{$requestsNowHashRef} ;
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
    my @dates_toDraw = sort keys  %timeReq ;
    # set plot format.
    my $chart = Chart::Gnuplot->new(
        output => "/tmp/$outputname.png",
        terminal => 'png',
        imagesize => "1000,500", 
        key => 'top left',
        title => {
            text => 'nginx requests',
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
        title => $dates_toDraw[-1],
        timefmt => '%H:%M',      # input time format
    );
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
#      PURPOSE: compare with history's mean record, set history outlier filter
#      1, 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
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


#-------------------------------------------------------------------------------
#  start here
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#  get requests result from log files. ( today )
#-------------------------------------------------------------------------------
my @logFiles = map { $_ . $logfilename } @logLocations;
my $requestsNowHashRef = getRequestsMinutely(@logFiles);
my $requestsToday = getRequestsToday(@logFiles);
my $requestHistoryHashRef = retrieve("$hashHistoryFile");
my ( $hist_Array_hash, $now_hash ) = getStatusDetail( $requestsNowHashRef,
    $requestHistoryHashRef);
#-------------------------------------------------------------------------------
#  check mean, sum, min, max with history and $threshhold, 
#    abs ($comparation) > $threshhold ?
#           alarm : next ;
#-------------------------------------------------------------------------------
my $errorStr;
my $mailSubj;
foreach my $statKey ( qw/mean sum min max/ ) {
    my $histdata = $hist_Array_hash->{$statKey};
    my $nowdata = $now_hash->{$statKey};
    my ($comparation, $filtered_index ) = getComparation( \@$histdata,
        $nowdata);
    if ( abs($comparation)>$threshhold ) {
        drawPic($requestsNowHashRef, $requestHistoryHashRef, "nginxPVHourly");
        drawPic($requestsToday, $requestHistoryHashRef, "nginxPVToday");
        my %hashValue ;
        my @hashFiltered ;
        my $updown = $comparation > 0 ? "+" : "-";
        $comparation = sprintf "%.2f%%", abs$comparation*100;
        $errorStr .= sprintf "%s %s%s\n",$statKey, $updown, $comparation;
        $mailSubj .= sprintf "%s%s%s_",$statKey, $updown, $comparation;
        $errorStr .= sprintf "  today: %i\n",$nowdata;
        @hashValue{sort keys
        %{$requestHistoryHashRef}}=map{s/$_/sprintf"%i",$_/eg; $_}@$histdata;
        $hashFiltered[$filtered_index]=" (filtered)";
        my $iterator = 0;
        foreach ( sort keys %hashValue ) {
            $errorStr .= sprintf "  %5s: %s",$_, $hashValue{$_} || "n/a";
            $errorStr .= $hashFiltered[$iterator] || "";
            $errorStr .= "\n";
            $iterator++;
        }
    }
}
foreach my $statKey ( qw/RSD/ ) {
    my $histdata = $hist_Array_hash->{$statKey};
    my $nowdata = $now_hash->{$statKey};
    my ($comparation, $filtered_index ) = getComparation( \@$histdata,
        $nowdata);
    if ( abs($comparation)>$threshhold ) {
        drawPic($requestsNowHashRef, $requestHistoryHashRef, "nginxPVHourly");
        drawPic($requestsToday, $requestHistoryHashRef, "nginxPVToday");
        my %hashValue ;
        my @hashFiltered ;
        if ( $comparation > 0 ) {
            my $updown = $comparation > 0 ? "+" : "-";
            $comparation = sprintf "%.2f%%", abs$comparation*100;
            $errorStr .= sprintf "%s %s%s\n",$statKey, $updown, $comparation;
            $mailSubj .= sprintf "%s%s%s_",$statKey, $updown, $comparation;
            $errorStr .= sprintf "  today: %.2f\n",$nowdata;
            @hashValue{sort keys
            %{$requestHistoryHashRef}}=map{s/$_/sprintf"%.2f",$_/eg;
            $_}@$histdata;
            $hashFiltered[$filtered_index]=" (filtered)";
            my $iterator = 0;
            foreach ( sort keys %hashValue ) {
                $errorStr .= sprintf "  %5s: %s",$_, $hashValue{$_} || "n/a";
                $errorStr .= $hashFiltered[$iterator] || "";
                $errorStr .= "\n";
                $iterator++;
            }
        }
    }
}

outputHtml($errorStr, $mailSubj);


#===  FUNCTION  ================================================================
#         NAME: outputHtml
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub outputHtml {
    my $errorOutput = shift ;
    my $mailSubj = shift;
    my $outputfilename = '/tmp/nginx_status_now.txt';
    open my $fho, ">", $outputfilename || die $!;
    say $fho "<pre>some errors may be occured:";
    say $fho $errorOutput ;
    say $fho "</pre>";
    close $fho ;
    if ( $mailSubj ) {
        my $systemCommand=qq#/opt/mmSdk/bin/nginx_mail.sh mmSdk-nginx-$mailSubj#;
        `$systemCommand`;
    }
} ## --- end sub outputHtml


