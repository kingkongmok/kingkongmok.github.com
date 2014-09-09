#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;
use Text::CSV;
use File::Temp qw/ tempfile tempdir/;

$CGI::POST_MAX = 1024 * 5000;
my $safe_filename_characters = "a-zA-Z0-9_.-";
#my $upload_dir = "/home/mywebsite/htdocs/upload";
my $upload_dir = "/tmp/upload";

my $query = new CGI;
my $filename = $query->param("filename");

if ( !$filename )
{
print $query->header ( );
print "There was a problem uploading your file (try a smaller file).";
exit;
}

my ( $name, $path, $extension ) = fileparse ( $filename, '..*' );
$filename = $name . $extension;
$filename =~ tr/ /_/;
$filename =~ s/[^$safe_filename_characters]//g;

if ( $filename =~ /^([$safe_filename_characters]+)$/ )
{
$filename = $1;
}
else
{
die "Filename contains invalid characters";
}

my $upload_filehandle = $query->upload("filename");

open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";
binmode UPLOADFILE;
while ( <$upload_filehandle> )
{
print UPLOADFILE;
}
close UPLOADFILE;

print $query->header, $filename . " is upload\n" ;

##my $file = "/home/kk/Downloads/bill.utf8.csv" || die "$!";
##my $csv = Text::CSV->new ({ binary => 1, });
#my $csv = Text::CSV->new({binary=>1});
##open my $io, "<", $file or die "$file: $!";
#
#open FH, "<:enconding(gbk)", "$upload_dir/$filename" || die "$!" ;
#my@file=readline(FH);
#
#my ($fh, $filename) = tempfile();
#open $fh, "> $filename";
##my @catalogs = ("天猫佣金（类目）",);
#
#my %result;
##my %ids;
#
#my %catalogs = (
#"T200P"=>"提现",
##"AS:收入金额（+元）";
##"售后维权(-) AS售后维权：天猫佣金"
#"售后维权"=>"售后维权(-) AS售后维权：天猫佣金",
##"售后维权：代扣交易退回积分"
##"代扣返点积分"
##"代扣款（扣款用途：天猫佣金（类目）"=>"淘宝客佣金代扣款",
#"天猫佣金"=>"淘宝客佣金代扣款",
##"天猫佣金（类目）"
##"线上支付服务费——信用卡快捷支付"
#"代扣返点积分"=>"代扣交易退回积分",
#);
#
#
#    for ( @file ) {
#        my $targetString;
#        my $id;
#        $_ =~ s/(?<=[^"])(\,)/",/g;
#        $_ =~ s/(\,)(?=[^"])/,"/g;
#        $_ =~ s/^"//;
#        $_ =~ s/"$//;
#        my @F = split/","/;
#
##-------------------------------------------------------------------------------
##  if column 11( pay detials is true.
##-------------------------------------------------------------------------------
#        foreach my $catalog ( keys %catalogs ) {
#            if ( $F[11] =~ /$catalog/ ) {
#                # get id from column 11.
#                if ( $F[11] =~ /(\d+)\D+$/ ) {
#                    my$id=$1;
#                    # put column6.7 to result hash.
#                    if ( exists $result{$id}{$catalog} ) {
#                        $result{$id}{$catalog}=$F[6]+$F[7]+$result{$id}{$catalog};
#                    }
#                    else {
#                        $result{$id}{$catalog}=$F[6]+$F[7];
#                    }
#                    last ;
#                }
#            }
##-------------------------------------------------------------------------------
##  if column 11 is empty. check culumn 2. the cach.
##-------------------------------------------------------------------------------
#            elsif ($F[2] =~ /$catalog/) {
#                if ( $F[2] =~ /T200P(\d+)/ ) {
#                    my$id=$1;
#                    if ( exists $result{$id}{$catalog} ) {
#                        $result{$id}{$catalog}=$F[6]+$F[7]+$result{$id}{$catalog};
#                    }
#                    else {
#                        $result{$id}{$catalog}=$F[6]+$F[7];
#                    }
#                    last ;
#                }
#            }
#            else {
#            }
#        }
#
#}
#
#
#foreach my $catalog (sort keys%catalogs ) {
#    print $fh "\t", $catalogs{$catalog} ;
#}
#print $fh "\n";
#foreach my $id (sort keys%result ) {
#    print $fh $id ;
#    foreach my $catalog ( sort keys%catalogs ) {
#        if ( defined $result{$id}{$catalog} ) {
#            print $fh "\t", $result{$id}{$catalog};
#        }
#        else {
#            print $fh "\t0";
#        }
#    }
#    print $fh "\n";
#}
#
#
#
