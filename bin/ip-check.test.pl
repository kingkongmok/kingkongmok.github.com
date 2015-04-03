#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
$ENV{"LANG"}='zh_CN.UTF-8';

my %iplist=(
'1.1.1.0~1.1.1.255'   =>  '地区一',
'1.1.2.0/24'       =>  '地区二',
);

my $fwip_file="/tmp/fwip.txt";
my $daynum=3;
my $limitq=20;
my $rate=0.85;
my %fwip;
my %initlist;
my %mask;
my %result;
my %apn;
my $thirtytwobits = 4294967295; # for masking bitwise not on 64 bit arch


sub argton
{
   my $arg          = shift;
   my $i = 24;
   my $n = 0;
   
   # dotted decimals
   if    ($arg =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) {
      my @decimals = ($1,$2,$3,$4);
      foreach (@decimals) {
         if ($_ > 255 || $_ < 0) {
	    return -1;
	 }
	 $n += $_ << $i;
	 $i -= 8;
      }
      return $n;
   }
   
   # bit-count-mask (24 or /24)
   $arg =~ s/^\/(\d+)$/$1/;
   if ($arg =~ /^\d{1,2}$/) {
      if ($arg < 1 || $arg > 32) {
         return -1;
      }
      for ($i=0;$i<$arg;$i++) {
         $n |= 1 << (31-$i);
      }
      return $n;
   }
   
   # hex
   if ($arg =~   /^[0-9A-Fa-f]{8}$/ || 
       $arg =~ /^0x[0-9A-Fa-f]{8}$/  ) {
      return hex($arg);
   }

   # invalid
   return -1;
}

sub ntoa 
{
   return join ".",unpack("CCCC",pack("N",shift));
}

sub deaggregate 
{
  my $start = shift;
  my $end   = shift;
  my $info  = shift;
  my $base = $start;
  my $step;
  while ($base <= $end)
  {
       $step = 0;
       while (($base | (1 << $step))  != $base) {
          if (($base | (((~0) & $thirtytwobits) >> (31-$step))) > $end) {
	     last;
	  }
          $step++;
       }
       my $ip_mask=ntoa($base)."/" .(32-$step);
	   $iplist{$ip_mask}=$info;
       $base += 1 << $step;
  }
}

sub get_net{
  my $ip = shift;
  my $mask   = shift;
  return 0 if(!$ip||!$mask);
  my @ip=split(/\./,$ip);
  my $net="";
  my $i;
  if($mask==32){
		return $ip;
	}else{
		for($i=0;$i<int($mask/8);$i++)
			{$net=$net."".($ip[$i]&255).".";}
		$net=$net."".($ip[$i]&(256-2**(8-int($mask%8))));
		for(;$i<3;$i++){$net=$net.".0";}
		return $net;
	}
	return 0;
}

sub iplist_init{
	foreach my $ip_mask (keys %iplist){
		my $info=$iplist{$ip_mask};
		if($ip_mask=~/^(\d+\.\d+\.\d+\.\d+)
					[~-]+
					(\d+\.\d+\.\d+\.\d+)$/ix){
			deaggregate(argton($1),argton($2),$info);
			delete $iplist{$ip_mask};
		}else{
		$ip_mask=~/^(\d+\.\d+\.\d+\.\d+)
					\/
					(\d+)$/ix or do{
			warn "WARNING: ip_mask format error: $ip_mask";}
		}
	}
	#print Dumper(%iplist);
		foreach my $ip_mask (keys %iplist){
		my $info=$iplist{$ip_mask};
		my $ip;
		my $mask;
		if($ip_mask=~/^(\d+\.\d+\.\d+\.\d+)
					\/
					(\d+)$/ix){
		$ip=$1;
		$mask=$2;
		my $net=get_net($ip,$mask);
		next if(!$net);
		next if(exists $initlist{$net}{mask} && $initlist{$net}{mask} <= $mask);
		$initlist{$net}{info}=$info;
		$initlist{$net}{ip_mask}=$ip_mask;
		$initlist{$net}{mask}=$mask;
		$mask{$mask}=1;
		}
		}
		#print Dumper(%initlist);
		#print Dumper(%mask);
}

sub fwip_init{
	open HD,$fwip_file or die "$!";
	while (my $line=<HD>) {
	chomp $line;
	next if(!$line);
	$line =~ /^(\d+\.\d+\.\d+\.\d+)\s+
		    (.+)$/ix or do {
		   	     warn "WARNING: line not in log format: $line";
				 next;
	   };
	  $fwip{$1}=$2;
}
	close HD;
		#print Dumper(%fwip);
}

sub addr_to_net{
	  my $ip = shift;
	  return 0 if(!$ip);
	  return $ip if(exists $initlist{$ip});
	  foreach my $mask (keys %mask) {
		my $net=get_net($ip,$mask);
		return $net if($net&&exists $initlist{$net}&&$initlist{$net}{mask}==$mask);
	  }
		return 0;
}

iplist_init();
fwip_init();
line: while (my $line=<DATA>) {
	chomp $line;
	next line if(!$line);
	$line =~ /^\[(.*)\]\s+
			 (\d+)\s+
			 ([0-9]*\.?[0-9]+)\s+
			 (\d+)\s+
			 (\d+|-)?\s+			#phone
			 (.*|-)\s+
			 (\d+\.\d+\.\d+\.\d+)\s+   #ip
			 (.*)\s+ #fwip
			 (GET|POST|-)\s+
			 \[(.*:\d+)\]\s+
			  (.+)\s+
			 \[(.*)\]\s+
			 \[(.*|-)\]\s+
			  (.*)$/ix or do {
		   	    # warn "WARNING: line not in log format: $line";
				 next line;
	   };
	my $phone=$5?$5:"-";
	my $other=$6?$6:"-";
	my $ip=$7;
	my $host=$10;
	my $nw;
	next line if(not $host=~/^(SERVERNAME):80$/);
	if(exists $fwip{$ip}){
		if($fwip{$ip}=~/CMNET-APN/i){
		$apn{$fwip{$ip}}{total}+=1;
		$apn{$fwip{$ip}}{phone}+=1 if($phone=~/^\d+$/);
		if($phone eq "-"){
		if($other eq "-"){
		$apn{$fwip{$ip}}{nophone}+=1;
		}else{
		$apn{$fwip{$ip}}{other}+=1;
		}
		}
		}
		next line;
	}else{
	$nw=addr_to_net($ip);
	next line if(!$nw);
	$result{$ip}{total}+=1;
	$result{$ip}{info}=$initlist{$nw}{info};
	$result{$ip}{phone}+=1 if($phone=~/^\d+$/);
	$apn{$initlist{$nw}{info}}{total}+=1;
	$apn{$initlist{$nw}{info}}{phone}+=1 if($phone=~/^\d+$/);
	if($phone eq "-"){
		if($other eq "-"){
		$result{$ip}{nophone}+=1;
		$apn{$initlist{$nw}{info}}{nophone}+=1;
		}else{
		$apn{$initlist{$nw}{info}}{other}+=1;
		$result{$ip}{other}+=1;
		}
	}}
}
close DATA;

print Dumper\%result;

__DATA__
[01/Apr/2015:00:00:12 +0800] 302 0.118 0 - - 1.1.1.132 - GET [SERVERNAME:80] /URI [Mozilla/5.0 (Linux; U; Android 4.2.2; zh-cn; SAMSUNG-GT-I9168_TD Release/1.15.2014 Browser/AppleWebKit/534.30 Build/JDQ39) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30] [gzip,deflate] - 563 [0.118]
[01/Apr/2015:00:00:12 +0800] 302 0.118 0 - - 1.1.2.12 - GET [SERVERNAME:80] /URI [Mozilla/5.0 (Linux; U; Android 4.2.2; zh-cn; SAMSUNG-GT-I9168_TD Release/1.15.2014 Browser/AppleWebKit/534.30 Build/JDQ39) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30] [gzip,deflate] - 563 [0.118]
