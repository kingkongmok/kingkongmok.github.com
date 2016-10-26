#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: yWatch.pl
#
#        USAGE: ./yWatch.pl  
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
#      CREATED: 10/25/2016 04:39:42 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use feature 'say';

my $videoPath = "/home/kk/Downloads/videos"; 


sub confirm{
   my $question=shift;
   my $reply = "";
   print "$question (y/n)?";
   while ($reply !~ m/^[yn]/i){ # allow for pedants who reply "yes" or "now" 
       chomp($reply=<STDIN>);
   }
   return $reply=~m/^y/i ? 1 : undef;
}

#-------------------------------------------------------------------------------
#  main
#-------------------------------------------------------------------------------

opendir (my $dh, $videoPath) || die $!; 
my %h; 
my @videoFiles =  
                grep { !$h{$_}++ }
                map{s/-\d+?\.(?:mp4|flv)//; $_}
                map $_->[0],
                sort { $a->[1] <=> $b->[1] }
                map [ $_, +(stat "$videoPath/$_")[9] ],
                grep{/\.(?:mp4|flv)$/} readdir $dh ; 

foreach my $file ( @videoFiles ) {
    system("mplayer $videoPath/\'$file\'\*");
    if ( confirm("remove file $file") ) {
        system("rm $videoPath/\'$file\'\*");
    }

}
