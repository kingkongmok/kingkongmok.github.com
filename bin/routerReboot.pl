#!/usr/bin/perl 
#===============================================================================
#
#         FILE: routerReboot.pl
#
#        USAGE: ./routerReboot.pl  
#
#  DESCRIPTION: reload pppoe to get new ip from ISP, then reply change to ddns.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 10/24/2013 12:48:36 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use lib '/home/kk/bin' ;
use password ;
my%password=&getpassword;


#===  FUNCTION  ================================================================
#         NAME: checkIfMatchIP
#      PURPOSE: check the current ip if match the $arg.
#   PARAMETERS: $ipAddress
#      RETURNS: boolean
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub checkIfIPDiff {
    my	( $ipAddress )	= @_;
    chomp(my $currentIP =  qx#/usr/bin/curl -s "ifconfig.me/ip"#);
    if ( $ipAddress eq $currentIP ) {
        return 0 ;
    }
    else {
        return 1;
    }
} ## --- end sub checkIfMatchIP


#===  FUNCTION  ================================================================
#         NAME: rebootRouter
#      PURPOSE: reboot the router using curl
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub rebootRouter {
    while ( 1 ) {
        my $htmlresult = qx#curl -q "http://$password{kk}{username}:$password{kk}{password}\@192.168.1.1/userRpm/StatusRpm.htm?Disconnect=%B6%CF%20%CF%DF&wan=1" 2>/dev/null # ;
        if ( $htmlresult =~ /You have no authority to access this router/ ) {
            last ;
        }
        else {
            sleep 1 ;
        }
    } 

    while ( 1 ) {
        my $htmlresult = qx#curl -q "http://$password{kk}{username}:$password{kk}{password}\@192.168.1.1/userRpm/StatusRpm.htm?Connect=%C1%AC%20%BD%D3&wan=1" 2>/dev/null # ;
        if ( $htmlresult =~ /You have no authority to access this router/ ) {
            last ;
        }
        else {
            sleep 1 ;
        }
    } 
#    print "router is rebooted.\n" ;
    return 1 ;
} ## --- end sub rebootRouter


#-------------------------------------------------------------------------------
#  do reboot the router unless connect to google.com
#-------------------------------------------------------------------------------
chomp(my $oldIP =  qx#/usr/bin/curl -s "ifconfig.me/ip"#) ;
my $pingtimes = 0 ;
while ( 1 ) {
#    print "ping $pingtimes times...\n" ;
    if ( $pingtimes % 30 == 0 ) {
        &rebootRouter ;    
    }
    $pingtimes++ ;
    my $pingresult = system("ping -q -c1 google.com > /dev/null");
    if ( $pingresult == 0 ) {
#        print "network is on.\n" ;
        if ( &checkIfIPDiff($oldIP) ) {
            #print "ip is not match\n";
            last ;
        }
    }
    else {
        sleep 3 ;
    }
}

#-------------------------------------------------------------------------------
#  renew the ddns.
#-------------------------------------------------------------------------------
while ( 1 ) {
    #my $htmlresult = qx#curl -q "http://$password{us}{username}:$password{kk}{password}\@members.3322.org/dyndns/update?system=dyndns&hostname=$password{us}{username}.3322.org&mx=$password{us}{username}.3322.org" 2>/dev/null #;
    my $htmlresult = qx#curl -s "http://freedns.afraid.org/dynamic/update.php?WGtJdk1zNXlkZ3hPakdGOU5xdTE6MTMwNjA4MzM="#;
    print "$htmlresult" ;
    if ( $htmlresult =~ /^Updated 1 host/ ) {
        last ;
    }
    else {
        sleep 2 ;
    }
} 
