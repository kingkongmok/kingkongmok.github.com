#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: logAnalyze.pl
#
#        USAGE: ./logAnalyze.pl  
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
#      CREATED: 01/27/2015 10:03:06 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;
use DDP;

my @logFiles = qw#
    /tmp/calendar_monitoring.log 
    /tmp/setting_monitoring.log
    #;

my $tempFileDir = "/tmp/testfolder";

my %interfaceField = (
        "RequestTime" =>  [ 
            8, {
                "user:getMainData"    =>  [ 11, "邮箱属性" ],
                "umc:getArtifact"     =>  [ 11, "用管中心凭证" ],
            }, 
            8, '(?<=RequestTime=)(\d+)' ] ,
    );

my @countTime = (50, 100, 150, 200, 300, 500, 1000, 120000);



#===  FUNCTION  ================================================================
#         NAME: dumpResult
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#==============================================================================
sub dumpResult {
    my	( $interfaceDescRef )	= @_;
    my($day, $month, $year) = (localtime)[3,4,5];
    $month = sprintf '%02d', $month+1;
    $day   = sprintf '%02d', $day;
    my $date =  $year+1900 . $month . $day;
    foreach my $intName (keys%$interfaceDescRef) {
        foreach my $modName ( keys${$interfaceDescRef}{$intName}{mod} ) {
#            my @append ;
#            foreach my $time ( @countTime ) {
#                if ( ${$interfaceDescRef}{$intName}{mod}{$modName}{time}{$time} ){
#                #print "$intName|$modName|${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount}|${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime}|$time|${$interfaceDescRef}{$intName}{mod}{$modName}{time}{$time}\n";
#                push @append,"${$interfaceDescRef}{$intName}{mod}{$modName}{time}{$time}";
#                }
#                my @printArray = ( $intName,
#                                $modName,
#                                ${$interfaceField{$intName}[1]}{$modName}[1],
#                                ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount},
#                                ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime},
##                                ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{$time}
#                                @append
#                );
#                print join"\t",@printArray;
#                print "\n"
#            }
                my @printArray = ( $intName,
                                $modName,
                                ${$interfaceField{$intName}[1]}{$modName}[1],
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount},
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime},
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"50%"},
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"100%"},
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"150%"},
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"200%"},
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"300%"},
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"500%"},
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"1000%"},
                                ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"120000%"},

                );
                print join"\t",@printArray;
                print "\n"
        }
#        print "$intName|count|${$interfaceDescRef}{$intName}{intCount}\n";
#        print "$intName|averagetime|${$interfaceDescRef}{$intName}{intAverageTime}\n"
    }
    return ;
} ## --- end sub dumpResult


#===  FUNCTION  ================================================================
#         NAME: getLogArray
#      PURPOSE: input filename and get log's @lines
#   PARAMETERS: $filenames
#      RETURNS: @lines
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getLogArray {
    #my $files = shift;
    my @lines;
    foreach my $file (@_) {
        open my $fh , "<", $file;
        push @lines, <$fh>;
        close $fh ;
    }
    return \@lines;
} ## --- end sub getLogArray



#===  FUNCTION  ================================================================
#         NAME: analyze
#      PURPOSE: input @lines and get @printArray
#   PARAMETERS: log's content @lines
#      RETURNS: \%interfaceDesc
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub analyze {
    my %interfaceDesc;
    my $linesRef = shift;
    for my $line ( @{$linesRef} ) {
        foreach my $intName ( keys %interfaceField ) {
            my @F = split /\|/,$line;
            my $timeRegex = $interfaceField{$intName}[3] ;
            my $timeNumb = $interfaceField{$intName}[2] ;
            my $intNumb = $interfaceField{$intName}[0]; 
            if ($F[$intNumb] =~ /\b$intName\b/) {
                $interfaceDesc{$intName}{intCount}++;
                $interfaceDesc{$intName}{intTotalTime}+= $& if $F[$timeNumb] =~ /$timeRegex/;
                if ( $interfaceDesc{$intName}{intTotalTime} && $interfaceDesc{$intName}{intCount}) {
                    $interfaceDesc{$intName}{intAverageTime}=sprintf"%.2f",($interfaceDesc{$intName}{intTotalTime}/$interfaceDesc{$intName}{intCount});
                foreach my $modName ( keys %{$interfaceField{$intName}[1]} ) {
                    my $modNumb = ${$interfaceField{$intName}[1]}{$modName}[0]; 
                    if ( $F[$modNumb] =~ /\b$modName\b/  ) {
                        if ($F[$timeNumb] =~ /$timeRegex/){
                            my $requesttime = $&;
                            foreach ( @countTime ) {
                                if ($requesttime < $_) {
                                    $interfaceDesc{$intName}{mod}{$modName}{time}{$_}++;
                                    last;
                                }
                            }
                            $interfaceDesc{$intName}{mod}{$modName}{count}{modTotalTime}+=$requesttime;
                            $interfaceDesc{$intName}{mod}{$modName}{count}{modCount}++;
                            foreach ( @countTime ) {
                                if ($interfaceDesc{$intName}{mod}{$modName}{time}{$_} && $interfaceDesc{$intName}{mod}{$modName}{count}{modCount} ){
                                    $interfaceDesc{$intName}{mod}{$modName}{percent}{$_."%"}= sprintf"%.2f",($interfaceDesc{$intName}{mod}{$modName}{time}{$_} / $interfaceDesc{$intName}{mod}{$modName}{count}{modCount} * 100);
                                }
                                else {
                                    $interfaceDesc{$intName}{mod}{$modName}{percent}{$_."%"}="0";
                                }
                                unless ($interfaceDesc{$intName}{mod}{$modName}{time}{$_} ){
                                    $interfaceDesc{$intName}{mod}{$modName}{time}{$_}=0
                                }
                            }
                        }
                    $interfaceDesc{$intName}{mod}{$modName}{count}{modAverageTime}=sprintf"%.2f",($interfaceDesc{$intName}{mod}{$modName}{count}{modTotalTime}/$interfaceDesc{$intName}{mod}{$modName}{count}{modCount});
                    }
                }
            }
            }
        }
    }
    return \%interfaceDesc;
} ## --- end sub analyze


#===  FUNCTION  ================================================================
#         NAME: mergeRusult
#      PURPOSE: get @printArray
#   PARAMETERS: %interfaceDesc, $tempFileDir, 
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub mergeRusult {
    my	( $interfaceDescRef, $tempFileDir )	= @_;
    chdir $tempFileDir;
    &dumpResult($interfaceDescRef);
    use File::Basename;
    my $filename = $& if $0 =~ /\w+(?=\.)/;
    foreach my $tempfile ( glob("$filename*") ) {
        open my $fh , "< $tempfile";
        #print <$fh>;
        close $fh;
    }
    return ;
} ## --- end sub mergeRusult


#===  FUNCTION  ================================================================
#         NAME: printTable
#      PURPOSE: print out table 
#   PARAMETERS: @printArray
#      RETURNS: print out ayalyze file and record file for counting increase 
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub printTable {
    my	( $par1 )	= @_;
    return ;
} ## --- end sub printTable


my $linesRef = getLogArray(@logFiles);
my %interfaceDesc = %{&analyze($linesRef)};
print Dumper \%interfaceDesc;
my @printArray = mergeRusult(\%interfaceDesc, $tempFileDir);


