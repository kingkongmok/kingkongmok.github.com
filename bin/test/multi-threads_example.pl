#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: multi-threads_example.pl
#
#        USAGE: ./multi-threads_example.pl
#
#  DESCRIPTION: example for multi-threads
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 12/17/2014 10:57:13 AM
#     REVISION: ---
#===============================================================================

use threads;
use threads::shared;

print "Starting main program\n";
my @threads;
for ( my $count = 1; $count <= 10; $count++) {
        my $t = threads->new(\&sub1, $count);
        push(@threads,$t);
}
foreach (@threads) {
        my $num = $_->join;
        print "done with $num\n";
}
print "End of main program\n";
sub sub1 {
        my $num = shift;
        print "started thread $num\n";
        sleep $num;
        print "done with thread $num\n";
        return $num;
}
