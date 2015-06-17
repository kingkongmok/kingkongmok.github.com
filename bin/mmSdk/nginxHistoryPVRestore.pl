#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: nginxPvCheck.pl
#
#        USAGE: ./nginxPvCheck.pl  
#
#  DESCRIPTION: decompress the nginx status logfile, and get a hash. crontab
#               job for daily
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

use strict;
use warnings;
use utf8;
use feature 'say';
use Fcntl 'O_RDONLY';
use Tie::File;
use Storable qw(store retrieve);

my $line_number = 60 ;

my @logLocations = qw#
    /home/logs/1_mmlogs/crontabLog/nginx/
    /home/logs/4_mmlogs/crontabLog/nginx/
    /home/logs/3_mmlogs/crontabLog/nginx/
    /home/logs/5_mmlogs/crontabLog/nginx/
#;

# my @logLocations = qw#
#     /home/kk/Documents/logs/nginx/1/
#     /home/kk/Documents/logs/nginx/2/
#     /home/kk/Documents/logs/nginx/3/
#     /home/kk/Documents/logs/nginx/5/
# #;

my $logfilename = "nginx_status.log";

my $hashFilename = "/tmp/nginxHistoryPV_backup.hash";


#===  FUNCTION  ================================================================
#         NAME: getHistoryReq
#      PURPOSE: get history handling requests by analyzing nginx_status.log.*gz
#               with Tie::File
#   PARAMETERS: @logs filename
#      RETURNS: %requestsMinutely = (
#                   06-16 => {
#                       '14:09' => 951776,
#                   }, 
#              ) 
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getHistoryReq (@) {
    my	@logFiles	= @_;
    use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
    my %requestsMinutely;
    my @hourlyLines;
    foreach my $filename ( @logFiles ) {
        if ( -e $filename ) {
            my $fileout = "/tmp/nginx_hislog_tmp.txt";
            gunzip $filename => $fileout or die "gunzip failed: $GunzipError\n";
            tie my @lines, 'Tie::File', $fileout, mode => "O_RDONLY" || die $!;
            # my $displayLine = $#lines - $line_number > 0 ? $#lines - $line_number : 0 ;
            # my @specifyLines = @lines[ $displayLine ..  $#lines ];
            # for ( my $i=1; $i<~~@specifyLines; $i++ ) {
            for ( my $i=1; $i<~~@lines; $i++ ) {
                $requestsMinutely{substr $lines[$i], -14, 5}{ substr $lines[$i], -8, 5 } += 
                    +(split/\s+/,$lines[$i])[9] > +(split/\s+/,$lines[$i-1])[9]
                    ? +(split/\s+/,$lines[$i])[9] -
                    +(split/\s+/,$lines[$i-1])[9] : +(split/\s+/,$lines[$i])[9]
                    ;
            }
            untie @lines;
        }
    }
    return \%requestsMinutely;
} ## --- end sub getHistoryReq


#-------------------------------------------------------------------------------
#  get request result from gzip files. (history)
#-------------------------------------------------------------------------------
my @historyLogFiles;
#
# compare with 7,14,21,28,35,42,48 day's ago
#my @historyFileSuffix = map {$_ . ".gz"} grep {$_%7 == 0}(1..56);
#
# compare with 1,2,3,4,5,6,7 day's ago
my @historyFileSuffix = map {$_ . ".gz"} (1..8);
foreach my $suffix ( @historyFileSuffix ) {
    push @historyLogFiles , map { $_ . $logfilename . "." .  $suffix } @logLocations;
}

my $requestsMinutely = &getHistoryReq(@historyLogFiles);


#-------------------------------------------------------------------------------
#  backup hash to file, using Storable->store.
#-------------------------------------------------------------------------------
store( $requestsMinutely, $hashFilename) || die $!;
