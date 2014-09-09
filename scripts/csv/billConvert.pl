#!/usr/bin/perl
#===============================================================================
#
#         FILE: billConvert.pl
#
#        USAGE: ./billConvert.pl  
#
#  DESCRIPTION:  春丽姐 convert taobao's bill to a form
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 10/24/2013 04:39:56 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Text::CSV;
use File::Temp qw/ tempfile tempdir/;

#my $file = "/home/kk/Downloads/bill.utf8.csv" || die "$!";
#my $csv = Text::CSV->new ({ binary => 1, });
my $csv = Text::CSV->new({binary=>1});
#open my $io, "<", $file or die "$file: $!";

open FH, "< /home/kk/Downloads/bill.utf8.csv" || die "$!" ;
my@file=readline(FH);

my ($fh, $filename) = tempfile();
open $fh, "> $filename";
#my @catalogs = ("天猫佣金（类目）",);

my %result;
#my %ids;

my %catalogs = (
"T200P"=>"提现",
#"AS:收入金额（+元）";
#"售后维权(-) AS售后维权：天猫佣金"
"售后维权"=>"售后维权(-) AS售后维权：天猫佣金",
#"售后维权：代扣交易退回积分"
#"代扣返点积分"
#"代扣款（扣款用途：天猫佣金（类目）"=>"淘宝客佣金代扣款",
"天猫佣金"=>"淘宝客佣金代扣款",
#"天猫佣金（类目）"
#"线上支付服务费——信用卡快捷支付"
"代扣返点积分"=>"代扣交易退回积分",
);


    for ( @file ) {
        my $targetString;
        my $id;
        $_ =~ s/(?<=[^"])(\,)/",/g;
        $_ =~ s/(\,)(?=[^"])/,"/g;
        $_ =~ s/^"//;
        $_ =~ s/"$//;
        my @F = split/","/;

#-------------------------------------------------------------------------------
#  if column 11( pay detials is true.
#-------------------------------------------------------------------------------
        foreach my $catalog ( keys %catalogs ) {
            if ( $F[11] =~ /$catalog/ ) {
                # get id from column 11.
                if ( $F[11] =~ /(\d+)\D+$/ ) {
                    my$id=$1;
                    # put column6.7 to result hash.
                    if ( exists $result{$id}{$catalog} ) {
                        $result{$id}{$catalog}=$F[6]+$F[7]+$result{$id}{$catalog};
                    }
                    else {
                        $result{$id}{$catalog}=$F[6]+$F[7];
                    }
                    last ;
                }
            }
#-------------------------------------------------------------------------------
#  if column 11 is empty. check culumn 2. the cach.
#-------------------------------------------------------------------------------
            elsif ($F[2] =~ /$catalog/) {
                if ( $F[2] =~ /T200P(\d+)/ ) {
                    my$id=$1;
                    if ( exists $result{$id}{$catalog} ) {
                        $result{$id}{$catalog}=$F[6]+$F[7]+$result{$id}{$catalog};
                    }
                    else {
                        $result{$id}{$catalog}=$F[6]+$F[7];
                    }
                    last ;
                }
            }
            else {
            }
        }

}


foreach my $catalog (sort keys%catalogs ) {
    print OUT "\t", $catalogs{$catalog} ;
}
print OUT "\n";
foreach my $id (sort keys%result ) {
    print OUT $id ;
    foreach my $catalog ( sort keys%catalogs ) {
        if ( defined $result{$id}{$catalog} ) {
            print OUT "\t", $result{$id}{$catalog};
        }
        else {
            print OUT "\t0";
        }
    }
    print OUT "\n";
}



