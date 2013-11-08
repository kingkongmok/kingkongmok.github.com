#!/usr/bin/perl
#===============================================================================
#
#         FILE: 3column.pl
#
#        USAGE: ./3column.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 10/16/2013 09:21:23 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

open my $fh, "< /home/kk/workspace/perl/3column.txt" || die "$!" ;

sub make_hd_aoa {
    my @aoa ;
    foreach my $rows ( @_ ) {
        push @aoa, ( [split/\s+/,$rows] ) ;
    }
    return @aoa;
} ## --- end sub makeaoa

#my @aoa = make_hd_aoa(<$fh>);

sub make_aoa_hoa {
#    my	( $par1 )	= @$_;
    my %h ;
    foreach my $rows ( @_ ) {
        my ($k, @v) = @$rows ;
        $h{$k}= [ @v ] ;
    }
    return %h;
} ## --- end sub make_aoa_hoa


sub make_fh_aoa {
    my%hash ;
    foreach my $item ( @_ ) {
        my ($k, $v) = split/\s+/,$item,2;
        $hash{$k} = [ split/\s+/,$v ] ;
    }
    return %hash;
} ## --- end sub make_fh_aoa

#my %hoa = make_aoa_hoa(@aoa) ;
my %hoa = make_fh_aoa(<$fh>) ;





use Data::Dumper;
print Dumper(\%hoa);

