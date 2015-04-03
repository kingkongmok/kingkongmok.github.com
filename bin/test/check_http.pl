#!/usr/bin/perl -l

use strict;
use warnings;
use LWP::Simple;

my ($url) = @ARGV ;
if (! head($url)) {
    print "Warnning: not response" ;
}
else {
    print "OK" ;
}
