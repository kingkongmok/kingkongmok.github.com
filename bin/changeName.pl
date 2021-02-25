#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: changeName.pl
#
#        USAGE: ./changeName.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 23/02/21 10:26:58
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Encode;
use Data::Dumper;
use feature 'say';
  use Encode qw/encode/;



my @trims = (
    '愛上陸',
    '钢化团汉化',
    '50',
    'C96',
);

my $backupDir = "changeNameBackup";
unless ( -d $backupDir ) {
    mkdir $backupDir
}

my @Files = glob("*.*");

foreach my $filename ( @Files ) {
    foreach my $trim ( @trims ) {
        #if ( $filename =~ /$trim/ ) {
        (my $newname = $filename ) =~ s#$trim##gs ; 
        say $filename;
        say $newname;
    }
    #}
}

# print Dumper @Files
# print Dumper @trim
