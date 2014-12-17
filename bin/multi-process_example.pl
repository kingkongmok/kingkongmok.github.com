#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: multi-process_example.pl
#
#        USAGE: ./multi-process_example.pl
#
#  DESCRIPTION: example for multi-process
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 12/17/2014 01:46:11 PM
#     REVISION: ---
#===============================================================================


use strict;
use warnings;
print "Starting main program\n";
my @childs;
for ( my $count = 1; $count <= 10; $count++) {
        my $pid = fork();
        if ($pid) {
        # parent
        #print "pid is $pid, parent $$\n";
        push(@childs, $pid);
        } elsif ($pid == 0) {
                # child
                sub1($count);
                exit 0;
        } else {
                die "couldnt fork: $!\n";
        }
 
}
foreach (@childs) {
        my $tmp = waitpid($_, 0);
         print "done with pid $tmp\n";
}      
print "End of main program\n";

sub sub1 {
        my $num = shift;
        print "started child process for  $num\n";
        sleep $num;
        print "done with child process for $num\n";
        return $num;
}
 
