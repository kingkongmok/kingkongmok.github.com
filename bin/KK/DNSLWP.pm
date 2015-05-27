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

package KK::DNSLWP;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = { 
                "_firstURL" => shift,
                "_loginURL" => shift,
                "_loginForm" => shift,
                "_modifyURL" => shift,
                "_modifyForm" => shift,
                "_besthost" => shift ,
                "_content" => undef ,
           };
    bless($self, $class);
    return $self;
}

sub getContent {
    my $self = shift;
    my $firstURL = $self->{_firstURL};
    my $loginURL = $self->{_loginURL};
    my $modifyURL =  $self->{_modifyURL};
    my $loginForm = $self->{_loginForm};
    my $modifyForm = $self->{_modifyForm};
    my $besthost = $self->{_besthost};
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
    $response = $ua->post($loginURL, $loginForm);
    ($modifyURL, $modifyForm) = &changeURL($modifyURL, $modifyForm, $cookie_jar, $besthost);
    $response = $ua->post($modifyURL, $modifyForm);
    my ($content, $hostArray);
    if ($response->is_success) {
        $content = $response->decoded_content;
        print $content;
    }
    else {
        die $response->status_line;
    }
    $self->{_content} =  $content;
    return $self->{_content};
} ## --- end sub getContent


#===  FUNCTION  ================================================================
#         NAME: changeURL
#      PURPOSE: change URL, set query string parameter and cookie
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub changeURL {
    my	( $modifyURL, $modifyForm , $cookie_jar, $besthost)	= @_;
    my $session_id = $1 if $cookie_jar->as_string =~ /_xsrf=(\S+);/;
    $modifyURL .=  $session_id ;
    use POSIX "strftime";
    my $timeString = strftime "%F %T",localtime time; 
    $modifyForm->{updated_on}=$timeString;
    $modifyForm->{value}=$besthost;
    return ($modifyURL, $modifyForm);
} ## --- end sub changeURL

1
