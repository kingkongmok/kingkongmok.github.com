#!/usr/bin/perl
#===============================================================================
#
#         FILE: chroot.pl
#
#        USAGE: ./chroot.pl  
#
#  DESCRIPTION: testing for chroot.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/25/2013 12:19:35 PM
#     REVISION: ---
#===============================================================================

use strict ;
use warnings;

#&showchroot_programming ;

sub showchroot_programming{
local $\="\n" ;
local $,="\t" ;

print "Here I am";
opendir my $rootdh, '/';

chroot( '/home/kk' );
opendir my $dh, '/'; # /home/kk
print readdir($dh);

chdir( $rootdh );
# oops, back to the real '/'
opendir $dh, '.';
print readdir($dh);
}
