#!/usr/bin/env perl
#
# Hidemyass Public Proxy List Retriever
# Stores output in proxies.txt file
# 
# Marcin Hlybin, ahes@sysadmin.guru
#
# Usage:
# npm install -g phantomjs
# ./hidemyass-proxy.pl
#
use warnings;
use strict;
use File::Slurp;
use Data::Dumper;
use Data::Validate::IP qw(is_ipv4);
use List::MoreUtils qw(uniq);
use Readonly;
no Smart::Comments;

Readonly my $PHANTOMJS => 'phantomjs';
Readonly my $JS        => 'phantomjs-hidemyass.js';
Readonly my $URL       => 'http://proxylist.hidemyass.com/search-1302871/';
Readonly my $FILENAME  => 'proxies.txt';

my ($page, $lastpage) = (1, 1);
my @proxies;

while(1) {
  last if $page > $lastpage;
  print "Getting page $page/$lastpage... ";
  my $lines = get_proxy_page($page);
  my $proxies = extract_proxies($lines);
  my $num_of_proxies = scalar @$proxies;
  print "found $num_of_proxies proxies\n";
  @proxies = (@proxies, @$proxies);
  $page++;
}

@proxies = uniq @proxies;
write_file($FILENAME, map { "$_\n" } @proxies);

sub get_proxy_page {
  my ($page) = @_;
  my $url = $URL . $page;

  my @lines = `$PHANTOMJS $JS $url`;
  chomp @lines;

  while (@lines) {
    my $line = shift @lines;
    last if $line =~ /^Last Update/;
  }

  if ($lastpage == 1) {
    my @pages;
    for (@lines) {
      push @pages, $_ if /^\d+$/;
    }
    $lastpage = $pages[-1];
  }

  return \@lines;
}

sub extract_proxies {
  my ($lines) = @_;
  my (@records, @proxies);
  my $num_of_lines = scalar @$lines;
  my $last_idx = $num_of_lines-1;

  for my $idx (0 .. $last_idx) {
    next unless $idx % 2;
    push @records, $lines->[$idx-1] . $lines->[$idx];
  }

  for my $record (@records) {
    my ($time, $ip, $port, $country, $scheme, $type);
    my @fields = split /\s+/, $record;

    # Field 2 is IP address
    if (is_ipv4($fields[1])) {
      ($time, $ip, $port, $country, $scheme) = splice(@fields, 0, 5);
      $type = join ' ', @fields;
    }
    # Field 3 is IP address
    elsif (is_ipv4($fields[2])) {
      my @time = splice(@fields, 0, 2);
      $time = join ' ', @time;
      ($ip, $port, $country, $scheme) = splice(@fields, 0, 4);
      $type = join ' ', @fields;
    }
    else {
      next;
    }
    ### $time
    ### $ip
    ### $port
    ### $country
    ### $scheme
    ### $type
    $scheme = lc $scheme;
    push @proxies, "$scheme://$ip:$port";
  }

  return \@proxies;
}
