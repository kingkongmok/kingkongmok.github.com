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


#===  FUNCTION  ================================================================
#         NAME: getElemDetail
#      PURPOSE: get @Element = ( suffix, interfaceValue, oldinterfaceValue, new/old )
#   PARAMETERS: 
#      RETURNS: @ElemDetail
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getElemDetail {
    my	( $suffix, $newVal, $oldVal, $wishUp, $average)	= @_;
    my ($percent, $prefix, $thirdElem, $color, $fontsuffix, $fontprefix, $percentMark) = ("")x7;
    my @ElemDetail ;
    # if both are exist
    if ( $newVal && $oldVal ) {
        # if both are not zero
        if ( $newVal != 0 && $oldVal != 0 ) {
            $percent = $newVal/$oldVal*100;
            if ( $average ) {
                
                if ( $percent > 100 ) {
                    $prefix = '+';
                    if ( $newVal > $average ) {
                        $color = "green" ;
                    } else {
                        $color = "red" ;
                    }
                }
                elsif ($percent>0 && $percent<100){
                    $prefix = '-';
                    if ( $newVal > $average ) {
                        $color = "red" ;
                    } else {
                        $color = "green" ;
                    }
                }
            }
            elsif ( $wishUp ) {
                if ( $wishUp eq "yes" ) {
                    if ( $percent > 100 ) {
                        $prefix = '+';
                        $color = "green";
                    }
                    elsif ($percent>0 && $percent<100) {
                        $prefix = '-';
                        $color = "red";
                    }
                }
                if ( $wishUp eq "no" ) {
                    if ( $percent > 100 ) {
                        $prefix = '-';
                        $color = "red";
                    }
                    elsif ($percent>0 && $percent<100) {
                        $prefix = '+';
                        $color = "green";
                    }
                }
            }
            $percent = sprintf"%.1f",abs($percent-100) ;
            if ( $percent > 40) {
                $fontprefix .= "<b>";
                $fontsuffix .= "<\/b>";
            } 
            if ($percent > 20 ) {
                $fontprefix .= "<font color='$color'>";
                $fontsuffix .= "<\/font>";
            }
            if ( $suffix ) {
                $newVal = sprintf"%.1f",$newVal;
                $oldVal = sprintf"%.1f",$oldVal;
            }
            $newVal .= $suffix ;
            $oldVal .= $suffix ;
            $thirdElem = "$fontprefix" . "$prefix" . "$percent" . "%" . "$fontsuffix";
            if ($percent == 0) {
                $thirdElem = "=="
            } 
        } 
        # if there is a zeror
        else {
            if ( $suffix ) {
                    $newVal = sprintf"%.1f",$newVal if $newVal;
                    $oldVal = sprintf"%.1f",$oldVal if $oldVal;
                }
            $newVal .= $suffix if $newVal;
            $oldVal .= $suffix if $oldVal;
            $thirdElem = "n/a";
        }
    } 
    # if there is a undef.
    else {
        if ( $suffix ) {
                $newVal = sprintf"%.1f",$newVal if $newVal;
                $oldVal = sprintf"%.1f",$oldVal if $oldVal;
            }
        $newVal .= $suffix if $newVal;
        $oldVal .= $suffix if $oldVal;
        $thirdElem = "n/a";
    }
    return ($newVal, $oldVal, $thirdElem);
} ## --- end sub getElemDetail


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
    my	( $interfaceDescRef , $interfaceDescRefOLD, $interfaceFieldREF, $countTimeREF)	= @_;
    my @countTime = @{$countTimeREF};
    my %interfaceField = %{$interfaceFieldREF};
    my @printArray ;
    foreach my $intName (keys%$interfaceDescRef) {
        push @printArray, (["<b><font color=blue>模块$intName</font></b>"], ["", "Description", "<b>访问</b>", "Last", "CMP", "", "<b>响应</b>", "Last", "CMP", "", "<b>0~50ms</b>", "Last", "CMP", "", "<b>50~100ms</b>", "Last", "CMP", "", "<b>100~150ms</b>", "Last", "CMP", "", "<b>150~200ms</b>", "Last", "CMP", "", "<b>200~300ms</b>", "Last", "CMP", "", "<b>300~500ms</b>", "Last", "CMP", "", "<b>500ms~1s</b>", "Last", "CMP", "", "<b>>1000ms</b>", "Last", "CMP"]) ;
        my @line = ( "整个接口信息", "all" );
        push @line, &getElemDetail("" , ${$interfaceDescRef}{$intName}{stat}{intCount}, ${$interfaceDescRefOLD}{$intName}{stat}{intCount} , "yes" , "");
        push @line, "";
        push @line, &getElemDetail("ms" , ${$interfaceDescRef}{$intName}{stat}{intAverageTime}, ${$interfaceDescRefOLD}{$intName}{stat}{intAverageTime} , "no" , "");
        push @printArray,[ @line ] ;
        foreach my $modName ( keys %{${$interfaceDescRef}{$intName}{mod}} ) {
            @line = ($modName, ${$interfaceField{$intName}[1]}{$modName}[1],);
            push @line, &getElemDetail("", ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modCount}, ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{count}{modCount}, "yes", "" );
            push @line, "";
            push @line, &getElemDetail("ms" ,${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime}, ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime}, "yes" , ""); 
            foreach ( @countTime ) {
            push @line, "";
            push @line, &getElemDetail("%", ${$interfaceDescRef}{$intName}{mod}{$modName}{percent}{"$_"."%"}, ${$interfaceDescRefOLD}{$intName}{mod}{$modName}{percent}{"$_"."%"}, "" , ${$interfaceDescRef}{$intName}{mod}{$modName}{count}{modAverageTime});
            }
            push @printArray,([@line]);
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
    unless (@lines) {
        die "there's NO content in log." ;
        exit 23 ;
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
    my $interfaceFieldREF  = shift ;
    my $countTimeREF  = shift ;
    my @countTime = @{$countTimeREF};
    my %interfaceField = %{$interfaceFieldREF};
    for my $line ( @{$linesRef} ) {
        foreach my $intName ( keys %interfaceField ) {
            my @F = split /\|/,$line;
            my $timeRegex = $interfaceField{$intName}[3] ;
            my $timeNumb = $interfaceField{$intName}[2] ;
            my $intNumb = $interfaceField{$intName}[0]; 
            if ($F[$intNumb] =~ /$intName/) {
                $interfaceDesc{$intName}{stat}{intCount}++;
                $interfaceDesc{$intName}{stat}{intTotalTime}+= $& if $F[$timeNumb] =~ /$timeRegex/;
                if ( $interfaceDesc{$intName}{stat}{intTotalTime} && $interfaceDesc{$intName}{stat}{intCount}) {
                    $interfaceDesc{$intName}{stat}{intAverageTime}=$interfaceDesc{$intName}{stat}{intTotalTime}/$interfaceDesc{$intName}{stat}{intCount};
                foreach my $modName ( keys %{$interfaceField{$intName}[1]} ) {
                    my $modNumb = ${$interfaceField{$intName}[1]}{$modName}[0]; 
                    if ( $F[$modNumb] =~ /$modName/  ) {
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
#         NAME: mergeResult
#      PURPOSE: get @printArray
#   PARAMETERS: %interfaceDesc, $tempFileDir, 
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub mergeResult {
    use Data::Dumper;
    my	( $interfaceDescRef, $tempFileDir, $filename, $nowdate, $olddate)	= @_;
    use Storable qw(store retrieve);
    my $newhashfile = "$tempFileDir/$filename" . "_hashdump_" . "$nowdate";
    store($interfaceDescRef, "$newhashfile") or die "Can't store %interfaceDescRef in $newhashfile!\n";
    my $interfaceDescRefOLD = ();
    my $oldhashfile = "$tempFileDir/$filename" . "_hashdump_" . "$olddate";
    if ( -r $oldhashfile ) {
        $interfaceDescRefOLD = retrieve("$oldhashfile"); 
    }
    my $txtfileoutName = "$tempFileDir/$filename" . "_data_" . "$nowdate" . ".txt";
    open my $txtFH, "> $txtfileoutName" ;
    print $txtFH Dumper $interfaceDescRef ;
    return ($interfaceDescRef, $interfaceDescRefOLD);
    #return &calcHashs($interfaceDescRef, $interfaceDescRefOLD);
} ## --- end sub mergeResult


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
    use CGI;
    my $cgi = new CGI;
    my $use_th = shift;
    my $transpose = shift;
    my $check_array_size = shift;
    my $border = shift;
    my $l_arrayREF = shift;
    my @l_array = @{$l_arrayREF};
    my $tempFileDir = shift;
    my $filename = shift;
    my $nowdate = shift;
    my $datesCompareWith = shift;
    my $htmlfileoutName = "$tempFileDir/$filename" . "_data_" . "$nowdate" . ".html";
    open my $htmlFH, "> $htmlfileoutName" ;
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
    print $htmlFH $cgi->h3("$filename" . "分析");
    print $htmlFH $cgi->table( {-border=>$border},
        $use_th?$cgi->th([@{shift @l_array}]):undef,
        map{$cgi->Tr(map{$cgi->td($_)}@$_)}@l_array
    );
    print $htmlFH $cgi->h5("Last是<b>$datesCompareWith日前</b>数据，CMP是对比<b>$datesCompareWith日前</b>的增长率");
}


1
