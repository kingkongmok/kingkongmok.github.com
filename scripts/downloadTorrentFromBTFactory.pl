#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use HTML::SimpleLinkExtor;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use threads;  
# mkdir 'C:\av';

my $btgc='http://69.46.87.53';
my @links=&get_links("$btgc/00/0401.html");
      @links=grep {/p2p/} @links;
      @links=map {$btgc.$_} @links;
foreach(@links){
      my @btlinks= &get_links($_);
      my %btlinks;
      $btlinks{$_}++ for @btlinks;
      @btlinks=grep {/file\.php/} keys %btlinks;
      say $_ for @btlinks;
      while(@btlinks){
         my $thr= threads->create(\&down_bt,$btlinks[0]); 
               $thr= threads->create(\&down_bt,$btlinks[0]) if shift @btlinks;   
               $thr= threads->create(\&down_bt,$btlinks[0]) if shift @btlinks;
               $thr->join();         }}
sub get_links{
      my $url=shift @_ or die "Hey,gimme a URL";
      my $ua=LWP::UserAgent->new;
            $ua->timeout(10);
                
      my $response=$ua->get($url)  or die "Could not get '$url'";
      unless($response->is_success){
                  die $response->status_line;
                  }
      my $html=$response->decoded_content;
      my $extractor=HTML::SimpleLinkExtor->new;
            $extractor->parse($html);
            return $extractor->links;
     }
     
 sub down_bt{
      my $btlink=shift @_ or die "Hey,gimme a URL";
            $btlink=~m#(http://[^/]+/\w+/)file\.php/(\w+)\.html#;
      my $down_link=$1;
      my $sn=$2;
      my $ua = LWP::UserAgent->new();
            $ua->timeout(60); 
            # $ua->proxy(['http', 'ftp'], 'http://127.0.0.1:8087/');
      my $url=$down_link.'down.php';
      my $arg={ 'type' =>'torrent',
                      'id' => $sn,
                      'name' => $sn
                    };
      # &perlPOST($arg,$url);
      # sub perlPOST(){
            # my($arg,$url)=@_;
      my $resp = $ua->post($url,$arg,'Content_Type' => 'form-data');
      my $filename=$arg->{name};
      open(my $fh,">","$filename.torrent");
      binmode($fh);
      print  $fh $resp->content;
      say "Have downloaded  $filename.torrent";
     close $fh;
      # }            
}
