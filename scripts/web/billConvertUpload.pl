#!/usr/bin/perl


use strict;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;
use File::Temp qw/ tempfile tempdir /;

my ($fh, $tempfile) = tempfile();
my $query = new CGI ;

#$CGI::POST_MAX = 1024 * 5000;
#
#my $query = new CGI;
my $filename = $query->param("filename");

#if ( !$filename )
#{
#print $query->header ( );
#print "There was a problem uploading your file .";
#exit;
#}
#
#
my $upload_filehandle = $query->upload("filename");
#
open ( UPLOAD, ">$tempfile" ) or die "$!";
binmode UPLOAD;
while ( <$upload_filehandle> )
{
print UPLOAD;
}
close UPLOAD;
#print $query->header, $tempfile . " is created\n" ;




open FH, "<:encoding(gbk)", "$tempfile" || die "$!" ;
my@file=readline(FH);

#open OUT, "> /tmp/test.file";
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

print $query->header;

    for ( @file ) {
        my $targetString;
        my $id;
        $_ =~ s/\r//;
        $_ =~ s/(?<=[^"])(\,)/",/g;
        $_ =~ s/(\,)(?=[^"])/,"/g;
        $_ =~ s/^"//;
        $_ =~ s/"$//;
        my @F = split/","/;

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
    print  "\t", $catalogs{$catalog} ;
}
print  "\n";
foreach my $id (sort keys%result ) {
    print  $id ;
    foreach my $catalog ( sort keys%catalogs ) {
        if ( defined $result{$id}{$catalog} ) {
            print  "\t", $result{$id}{$catalog};
        }
        else {
            print  "\t0";
        }
    }
    print  "\n";
}
