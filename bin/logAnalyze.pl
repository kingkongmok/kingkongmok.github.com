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
#use warnings;
use Data::Dumper;
use CGI::Pretty qw(:standard);

my @logFiles = qw#
    /tmp/calendar_monitoring.log 
    /tmp/setting_monitoring.log
    #;


my %interfaceField = (
        "RequestTime" =>  [ 
            8, {
                "user:getMainData"    =>  [ 11, "邮箱属性" ],
                "umc:getArtifact"     =>  [ 11, "用管中心凭证" ],
            }, 
            8, '(?<=RequestTime=)(\d+)' ] ,
    );




#-------------------------------------------------------------------------------
#  Don't edit below
#-------------------------------------------------------------------------------

my @countTime = (50, 100, 150, 200, 300, 500, 1000, 120000);
my ($dirname, $filename) = ($1,$3) if $0 =~ m/^(.*)(\\|\/)(.*)\.([0-9a-z]*)/;
my($day, $month, $year) = (localtime)[3,4,5];
my $nowdate =  $year+1900 . sprintf"%02d",$month+1 . sprintf"%02d",$day;
my $NUM_DAYS = 7;
my $time = time();
my ($oldday,$oldmonth,$oldyear)=+(localtime (time() - (60*60*24*7)))[3,4,5];
my $olddate =  $oldyear+1900 . sprintf"%02d",$oldmonth+1 . sprintf"%02d",$oldday;
my $tempFileDir = "$dirname/logAnalyzeTemp";
unless ( -d $tempFileDir ) {
    mkdir $tempFileDir;
}

#===  FUNCTION  ================================================================
#         NAME: calcHashs
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#==============================================================================
sub calcHashs {
    my	( $interfaceDescRef , $interfaceDescRefOLD)	= @_;
    my @printArray = (["name", "desc", "pv", "LW", "CMP", "|", "resp", "LW", "CMP", "|", "0~50ms(%)", "LW", "CMP", "|", "50~100ms(%)", "LW", "CMP", "|", "100~150ms(%)", "LW", "CMP", "|", "150~200ms(%)", "LW", "CMP", "|", "200~300ms(%)", "LW", "CMP", "|", "300~500ms(%)", "LW", "CMP", "|", "500ms~1000ms(%)", "LW", "CMP", "|", ">1000ms(%)", "LW", "CMP"]);
    foreach my $intName (keys%$interfaceDescRef) {
        foreach my $modName ( keys${$interfaceDescRef}{$intName}{mod} ) {
            my @contentArray = ();
            push @contentArray,$modName;
            push @contentArray, ${$interfaceField{$intName}[1]}{$modName}[1];
            # pv
            push @contentArray, ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount};
            push @contentArray, ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modCount};
            my $contentTemp =  (${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount} && ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modCount})?${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount}/${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modCount}*100:0;
            if ($contentTemp == 100) {
                push @contentArray, '==';
            }
            elsif ($contentTemp == 0) {
                push @contentArray, 'n/a';
            }
            else {
                push @contentArray, sprintf("%s",$contentTemp>100?"+":"-") . sprintf("%.1f",abs($contentTemp-100)) . "%";
            }
            push @contentArray,"|";
            # response
            push @contentArray, sprintf ("%.2f",${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime}) . "ms";
            push @contentArray, sprintf ("%.2f",${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modAverageTime}) . "ms";
            $contentTemp = (${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime} && ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modAverageTime})?${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime}/${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modAverageTime}*100:0;
            if ($contentTemp == 100) {
                push @contentArray, '==';
            }
            elsif ($contentTemp == 0) {
                push @contentArray, 'n/a';
            }
            else {
                push @contentArray, sprintf("%s",$contentTemp>100?"+":"-") . sprintf("%.1f",abs($contentTemp-100)) . "%";
            }
            push @contentArray,"|";
            # percents
            foreach ( @countTime ) {
                push @contentArray, sprintf ("%.2f",${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"}) . "%";
                push @contentArray, sprintf ("%.2f",${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"}) . "%";
                $contentTemp = (${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"} && ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"})?${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"}/${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"}*100:0;
                if ($contentTemp == 100) {
                    push @contentArray, '==';
                }
                elsif ($contentTemp == 0) {
                    push @contentArray, 'n/a';
                }
                else {
                    push @contentArray, sprintf("%s",$contentTemp>100?"+":"-") . sprintf("%.1f",abs($contentTemp-100)) . "%";
                }
                push @contentArray,"|";
            }
            push @printArray,([@contentArray]);
        }
    }
    return \@printArray;
} ## --- end sub calcHashs


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
                $interfaceDesc{$intName}{stat}{intCount}++;
                $interfaceDesc{$intName}{stat}{intTotalTime}+= $& if $F[$timeNumb] =~ /$timeRegex/;
                if ( $interfaceDesc{$intName}{stat}{intTotalTime} && $interfaceDesc{$intName}{stat}{intCount}) {
                    $interfaceDesc{$intName}{stat}{intAverageTime}=$interfaceDesc{$intName}{stat}{intTotalTime}/$interfaceDesc{$intName}{stat}{intCount};
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
                                    $interfaceDesc{$intName}{mod}{$modName}{percent}{$_."%"}= $interfaceDesc{$intName}{mod}{$modName}{time}{$_} / $interfaceDesc{$intName}{mod}{$modName}{count}{modCount} * 100;
                                }
                                else {
                                    $interfaceDesc{$intName}{mod}{$modName}{percent}{$_."%"}="0";
                                }
                                unless ($interfaceDesc{$intName}{mod}{$modName}{time}{$_} ){
                                    $interfaceDesc{$intName}{mod}{$modName}{time}{$_}=0
                                }
                            }
                        }
                    $interfaceDesc{$intName}{mod}{$modName}{count}{modAverageTime}=$interfaceDesc{$intName}{mod}{$modName}{count}{modTotalTime}/$interfaceDesc{$intName}{mod}{$modName}{count}{modCount};
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
    use Storable qw(store retrieve);
    my $newhashfile = "$tempFileDir/$filename" . "_hashdump_" . "$nowdate";
    store($interfaceDescRef, "$newhashfile") or die "Can't store %interfaceDescRef in $newhashfile!\n";
    my $interfaceDescRefOLD = ();
    my $oldhashfile = "$tempFileDir/$filename" . "_hashdump_" . "$olddate";
    if ( -r $oldhashfile ) {
        $interfaceDescRefOLD = retrieve("$oldhashfile"); 
    }
    return &calcHashs($interfaceDescRef, $interfaceDescRefOLD);
} ## --- end sub mergeRusult


#===  FUNCTION  ================================================================
#         NAME: make_table_from_Aoa
#      PURPOSE: 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
####################
#
#   make_table_from_Aoa
#
#   parameters
#   1)  $use_th : if this is true, the first line of the passed array will be used
#                   as an HTML header.
#   2)  $transpose : swap axis of array
#   3)  $check_array_size : if true, make sure each array has same # of elements
#   4)  $border : size of border to put around table.
#   5)  @l_array : holding tank for passed array.
#
####################
sub make_table_from_AoA {
    my $use_th = shift;
    my $transpose = shift;
    my $check_array_size = shift;
    my $border = shift;
    my @l_array = @_;
    my $fileoutName = "$tempFileDir/$filename" . "_data_" . "$nowdate" . ".html";
    open my $fileout, "> $fileoutName" ;
    #Make sure arrays are the same size. if not, die.
    if ($check_array_size){
        my $size =scalar(@{$l_array[0]});
        map  {die "funky arrays : First array is $size, found one of ".scalar(@{$_}) if scalar(@{$_}) != $size}@l_array;
    }
    if ($transpose) {
        my @tary;
        map {my $x=0;
            map {push @{$tary[$x]}, $_;$x++;} @$_;
        } @l_array;
        @l_array=@tary;
    }
    print $fileout h3("$filename" . "分析");
    print $fileout table( {-border=>$border},
        $use_th?th([@{shift @l_array}]):undef,
        map{Tr(map{td($_)}@$_)}@l_array
    );
    print $fileout h5("pv是只该模块访问的数量，resp是指相应毫秒数，LW是上周数据，CMP是对比上周的增长率");
}


my $linesRef = &getLogArray(@logFiles);
my %interfaceDesc = %{&analyze($linesRef)};
#print Dumper \%interfaceDesc;
my @printArray = &mergeRusult(\%interfaceDesc, $tempFileDir);
&make_table_from_AoA(0,1,1,1,@printArray);

