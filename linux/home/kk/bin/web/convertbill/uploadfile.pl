#!/usr/bin/perl


use strict;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

$CGI::POST_MAX = 1024 * 5000;
my $upload_dir = "/tmp";

my $query = new CGI;
my $filename = $query->param("filename");

if ( !$filename )
{
print $query->header ( );
print "There was a problem uploading your file (try a smaller file).";
exit;
}

$filename = "billconvertinput.csv";

my $upload_filehandle = $query->upload("filename");

open ( UPLOADFILE, ">$upload_dir/$filename" ) or die "$!";
binmode UPLOADFILE;
while ( <$upload_filehandle> )
{
print UPLOADFILE;
}
close UPLOADFILE;

#print $query->redirect('./welcome.txt');
print $query->redirect('./billConvert.pl');
#print $query->redirect("./hello.pl");
