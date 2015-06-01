#!/usr/bin/env perl

use 5.014;
use strict;
use warnings;
print "$$\n" ;
my $pid = fork;
print "$$\n" ;

if (!defined $pid) {
    die "Cannot fork: $!";
}
elsif ($pid == 0) {
    # client process
    say "Client starting... I'm $$";
    sleep 2; # do something useful instead!
    say "Client terminating, I'm $$";
    exit 0;
}
else {
    # parent process
    say "Parent process, waiting for child..., I'm $$";
    # do something useful here!
    waitpid $pid, 0;
}
say "Parent process after child has finished, I'm $$";
