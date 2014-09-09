#
#===============================================================================
#
#         FILE: Mlocate.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/29/2014 11:41:32 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


sub getMlocateResults {
    my	( $searchPatten, $locatedbFile )	= @_;
    $locatedbFile ||= '/var/lib/mlocate/mlocate.db' || die $!;
    my %results ;
    if ( -r $locatedbFile ) {
        foreach my $word ( @{$searchPatten} ) {
            print "search $word ...\n";
            #my $thisResult = qx#/usr/bin/locate -d $locatedbFile -i -r "$word"# || die $! ;
            my $thisResult = qx#/usr/bin/locate -d $locatedbFile -i -r "$word"# ;
            $results{$word}=$thisResult ;
        }
    }
    return %results;
} ## --- end sub mlocate
 
1;
