#
#===============================================================================
#
#         FILE: VPNLWP.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 05/26/2015 11:28:08 AM
#     REVISION: ---
#===============================================================================

package KK::VPNLWP;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = { 
                "_username" => shift,
                "_password" => shift,
                "_firstURL" => shift,
                "_loginURL" => shift,
                "_listURL" => shift,
                "_content" => undef ,
                "_bestHost" => undef ,
           };
    bless($self, $class);
    return $self;
}

sub getContent {
    my $self = shift;
    my $username = $self->{_username};
    my $password = $self->{_password};
    my $firstURL = $self->{_firstURL};
    my $loginURL = $self->{_loginURL};
    my $listURL =  $self->{_listURL};
    use LWP::UserAgent;
    use HTTP::Cookies;
    my $cookie_jar = HTTP::Cookies->new( );
    my $ua = LWP::UserAgent->new;
    $ua->cookie_jar( $cookie_jar );
    $ua->timeout(10);
    $ua->env_proxy;
    $ua->default_header(
        'Accept-Language' => "en-US,en;q=0.8,zh-TW;q=0.6,zh;q=0.4,zh-CN;q=0.2", 
        'Accept-Encoding' => "gzip, deflate",
        'Pragma' => 'no-cache',
        'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.76 Safari/537.36 ',
        'Content-Type' => 'application/x-www-form-urlencoded',
    );
    my $response =  $ua->post( $firstURL ); 
    my %form = ( 
                "rurl" => "", 
                "user_email" => $username,
                "user_pass" => $password,
                "remember" => 1,
    );
    $response = $ua->post($loginURL, \%form);
    $response = $ua->post($listURL);
    my ($content, $hostArray);
    if ($response->is_success) {
        $hostArray = join " ",
                    +($response->decoded_content  =~ m#<option value=\"(.+?)\">\1#g );
        $content = $response->decoded_content;
    }
    else {
        die $response->status_line;
    }
    $self->{_content} =  $content;
    return $self->{_content};
} ## --- end sub getContent


sub getBestHost {
    my ( $self, $content ) = @_;
    my $hostArray = join " ",
                +($self->{_content}  =~ m#<option value=\"(.+?)\">\1#g );
#-------------------------------------------------------------------------------
#  /usr/sbin/fping
#  -s   Print cumulative statistics upon exit.
#  -q   Quiet. Don't show per-probe results, but only the final summary. Also 
#        don't show ICMP error messages.
#  -c   n Number of request packets to send to each target.  In this mode, 
#        a line is displayed for each received response (this can suppressed 
#        with -q or -Q).  Also, statistics about responses for each target 
#        are displayed when all requests have been sent (or when interrupted).
#-------------------------------------------------------------------------------
    my @fpingResult = `sudo fping -s -q -c 10 $hostArray 2>&1` ;
#-------------------------------------------------------------------------------
#  [ "fpingResult", "lostRate", "response time" ] ;
#-------------------------------------------------------------------------------
    my @host_Schwartzian_AOA;              
    foreach (@fpingResult) {
        if ( $_ =~ /^\w/ ) {
             $_ =~ m{.*/
                    (\d+)           # $1, as lostRate% in INTEGER
                    \%.*?/
                    ([^/]*?)        # $2, as average msec respone time
                    /[^/]*?$}x ; 
             if ( defined  $1 && defined $2 ) {
                 push @host_Schwartzian_AOA , [ "$_" , "$1", "$2" ];
             }
        }
    }
    my @SortedHostArray = map { $_->[0] } 
                          sort {
                               $a->[1] <=> $b->[1]   # sort the lostRate  
                               ||
                               $a->[2] <=> $b->[2]   # then the response time
                          }
                          @host_Schwartzian_AOA ;
    my $bestProxy = +(                          # choose the 1st 
                        map {s/^(\S+).*/$1/r}   # first colum for the @SortedHostArrayn
                        @SortedHostArray        
                    )[0];                      
    chomp ( $bestProxy );
    $self->{_bestHost} = $bestProxy;
    return $self->{_bestHost} ;
} ## --- end sub getBestHost

1
