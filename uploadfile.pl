#!/usr/bin/perl


use strict;
use warnings;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

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
