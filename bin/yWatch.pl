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


#-------------------------------------------------------------------------------
#  usage
#-------------------------------------------------------------------------------
use Getopt::Std;
getopts('ht');
our($opt_h, $opt_t);

sub usage {
    print <<HELPTEXT;                                                           
    mplayer the videos and ask for delete
    options:
            -h          print this help                      
    exmaple:
            $0       # defualt dir ~/Downloads/videos
            $0 .     # this dir

HELPTEXT
}

my $Path = shift // "/home/kk/Downloads/videos"; 


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

if ( $opt_h ) {
    usage;
    exit 23;
}

opendir (my $videodh, $Path) || die $!; 
my %h; 
my @videoFiles =  
grep { !$h{$_}++ }
map{s/-\d+?\.(?:mp4|flv|avi|mkv)//; $_}
map $_->[0],
sort { $a->[1] <=> $b->[1] }
map [ $_, +(stat "$Path/$_")[9] ],
grep{/\.(?:mp4|flv|avi|mkv)$/} readdir $videodh ; 

opendir (my $comixdh, $Path) || die $!; 
my @comixFiles =  
grep { !$h{$_}++ }
map{s/-\d+?\.(?:zip|rar|tar)//; $_}
map $_->[0],
sort { $a->[1] <=> $b->[1] }
map [ $_, +(stat "$Path/$_")[9] ],
grep{/\.(?:zip|rar|tar)$/} readdir $comixdh ; 

foreach my $file ( @videoFiles ) {
    my $fileprefixname = $Path . "/" . $file ; 
    system("mplayer \"$fileprefixname\"\*");
    if ( confirm("remove file $file\*") ) {
        system("rm \"$fileprefixname\"\*");
    }
}

foreach my $file ( @comixFiles ) {
    my $fileprefixname = $Path . "/" . $file ; 
    system("mcomix \"$fileprefixname\"\*");
    if ( confirm("remove file $file\*") ) {
        system("rm \"$fileprefixname\"\*");
    }
}
