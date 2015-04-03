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
my %hoa = make_fh_aoa(<DATA>) ;





use Data::Dumper;
print Dumper(\%hoa);

__DATA__
b   0   0
c   1   1
d   2   2
e   3   3
f   4   4
g   5   5
h   6   6
i   7   7
j   8   8
k   9   9
b   3   3
c   4   4
d   5   5
a   5   20
e   6   6
f   7   7
g   8   8
h   9   9
i   10  10
j   11  11
k   12  12
b   2   2
c   3   3
d   4   4
e   5   5
f   6   6
g   7   7
h   8   8
i   9   9
j   10  10
k   11  11
