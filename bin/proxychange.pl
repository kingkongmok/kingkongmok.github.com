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
use KK::DNSLWP;
use lib '/home/kk/.private';
use GetPassword;

sub get_vpn_host {
    my $pas = new GetPassword;
    my $username = $pas->set_vpnso("username");
    my $password = $pas->set_vpnso("password");
    my $firstURL = $pas->set_vpnso("firstURL");
    my $loginURL = $pas->set_vpnso("loginURL");
    my $listURL = $pas->set_vpnso("listURL");
    my $vpn = KK::VPNLWP->new($username, $password, $firstURL, $loginURL,
        $listURL);
    my $content = $vpn->getContent;
    my $besthost = $vpn->getBestHost;
    return $besthost;
}

sub get_dns_host {
    my $besthost = shift;
    my $pas = new GetPassword;
    my $firstURL = $pas->set_dns("firstURL");
    my $loginURL = $pas->set_dns("loginURL");
    my $loginForm = $pas->set_dns("loginForm");
    my $modifyURL = $pas->set_dns("modifyURL");
    my $modifyForm = $pas->set_dns("modifyForm");
    my $dns = KK::DNSLWP->new($firstURL, $loginURL, $loginForm, $modifyURL,
        $modifyForm, $besthost);
    my $content = $dns->getContent;
# print $host
}

my $besthost;
$besthost = get_vpn_host ;
get_dns_host($besthost) 
