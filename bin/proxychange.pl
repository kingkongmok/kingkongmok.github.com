#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 05/26/2015 03:13:31 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use lib '/home/kk/bin';
use KK::VPNLWP;
use lib '/home/kk/.private';
use GetPassword;

my $pas = new GetPassword;

my $username = $pas->set_vpnso("username");
my $password = $pas->set_vpnso("password");
my $firstURL = $pas->set_vpnso("firstURL");
my $loginURL = $pas->set_vpnso("loginURL");
my $listURL = $pas->set_vpnso("listURL");

my $vpn = KK::VPNLWP->new($username, $password, $firstURL, $loginURL,
    $listURL);

my $content = $vpn->getContent;
my $host = $vpn->getBestHost;

# print $host
