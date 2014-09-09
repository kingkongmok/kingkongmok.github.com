#!/usr/bin/perl
#===============================================================================
#
#         FILE: dropboxDiff.pl
#
#        USAGE: ./dropboxDiff.pl  
#
#  DESCRIPTION: show the difference between dropbox dir andh home diff
#
#      OPTIONS: by defaults, show only what's new in dropbox , 
#               and -a show all differece; ;
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 12/04/2013 12:12:37 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


chomp(my @filelist = qx#find ~/Dropbox/ -path ~/Dropbox/.dropbox -prune -o -path ~/Dropbox/Public/.dropbox -prune -o -path ~/Dropbox/.dropbox.cache -prune -o  -type f  -print# );

my @noexistfile ;

print "\n========== files is different ========\n";
foreach my $file ( @filelist ) {
    if ( ( my $localfile = $file ) =~ s/Dropbox\/// ) {
        if ( -r $localfile ) {
            my $outputdiff = qx#diff -q $localfile $file #;
                if ( $outputdiff =~ /Files (.*) and (.*) differ/){
                    print "diff \"$2\" \"$1\"\n";
                }
                ;
#            if ( $outputdiff =~ s/^Files\s+/diff "/ ) {
#                if ( $outputdiff =~ s/ and /\" \"/ ) {
#                    if ( $outputdiff =~ s/ differ$/"/ ) {
#                        print $outputdiff ;
#                    }
#                }
#            }
        }
        else {
            push @noexistfile, $localfile ;
        }
    }
}
print "\n========== files is not exists ========\n";
foreach  my $file ( @noexistfile  ) {
    print "$file\n" if ( $file =~ s#/home/kk/## );
}

sub mergefiles {
    chdir "$ENV{HOME}/Dropbox" || die $! ;
    print "\n\ntrying to merge these files?[yes]\n";
    chomp(my $input = <STDIN>);
    if ( $input eq "yes" ) {
        foreach my $file ( @noexistfile ) {
            while ( 1 ) {
                print "copy $file ?[a/y/n/q]" ;
                chomp(my $ifcopy = <STDIN>);
                if ( $ifcopy eq 'a' ) {
                    foreach my $copyfile ( @noexistfile ) {
                        system("/bin/cp -auv --parents $copyfile ~");
                    }
                    print "copied all\n";
                    return 1;
                }
                if ( $ifcopy eq 'q' ) {
                    print "quit\n" ;
                    return 0;
                }
                if ( $ifcopy eq 'y' ) {
                    system("/bin/cp -auv --parents $file ~");
                    last ;
                }
                if ( $ifcopy eq 'n' ) {
                    print "not going to copy $file\n";
                    last ;
                }
            }
            
        }
    }
    else {
        return 0;
    }
    return 1;
} ## --- end sub mergefiles

if ( ~~@noexistfile ) {
    &mergefiles ;
}
