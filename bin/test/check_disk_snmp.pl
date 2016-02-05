#!/usr/bin/perl
###
### -- Nagios plugin for checking HOST-RESOURCES-MIB::hrStorage on remote hosts
###
 
use strict;
use warnings;
use vars qw($VERSION $VERBOSE $PROGNAME $OID_BASE);
use lib "/usr/local/nagios/libexec";
use lib "/usr/lib64/nagios/plugins";
use utils qw(%ERRORS $TIMEOUT &print_revision);		## - nagios helpers
use Socket qw(inet_aton);				## - hostname lookup
use Net::SNMP;

$VERSION	= 2.11;
$PROGNAME	= 'check_disk_snmp';
$OID_BASE	= '.1.3.6.1.2.1.25.2.3.1';
$VERBOSE	= 0;

sub print_version ();
sub print_usage ();
sub print_help ();
sub croak (;$);
sub commify ($);
sub shift_argv ($);
sub lookup_desc ($;$);

my $snmp	= q{};					## - snmp methods
my $resp	= q{};					## - snmp response
my $host	= q{};					## - host address
my $port	= 161;					## - snmp port
my $comm	= 'public';				## - snmp community
my $index	= q{};					## - device index
my $desc	= q{};					## - device description
my $warn	= '85%';				## - warning threshold
my $crit	= '90%';				## - critical threshold
my $state	= q{};					## - nagios state
my $devDesc	= q{};					## - description oid
my $devUnit	= q{};					## - allocation unit oid
my $devSize	= q{};					## - size oid
my $devUsed	= q{};					## - used oid
my $perc	= 0;					## - device percent used
my $free	= 0;					## - device free space
my $size	= 0;					## - device size
my %unit_t	= (					## - units table
  'KB'		=> 1 << 10,
  'MB'		=> 1 << 20,
  'GB'		=> 1 << 30,
);
my $unit_desc	= 'MB';					## - unit description
my $unit_sz	= $unit_t{$unit_desc};			## - unit size in bytes

sub print_version () {
###
### -- display plugin revision

  print STDOUT "$PROGNAME $VERSION\n";
}

sub print_usage () {
###
### -- display usage help

  print "\nUsage: ${PROGNAME} -H host_address [-s snmp_community]\n",
             "\t[-p snmp_udp_port] [-d device_description_or_index]\n",
             "\t[-w warning_threshold] [-c critical_threshold]\n",
	     "\n",
	     "\tConvenience abbreviations:\n",
	     "\tUse single letter [A-Z] device description for windows drive\n",
	     "\tUse \"phys\" device_description for \"Physical Memory\"\n",
	     "\tUse \"real\" device_description for \"Real Memory\"\n",
	     "\tUse \"swap\" device_description for \"Swap Space\"\n",
	     "\tUse \"virt\" device_description for \"Virtual Memory\"\n",
	     "\n";
}

sub print_help () {
###
### -- display extended usage help

  print_revision($PROGNAME, $VERSION);

  print	"\nThis plugin checks the amount of used disk and memory on\n",
	"remote hosts via snmp query of HOST-RESOURCES-MIB::hrStorage\n";

  print_usage;

  print	"Options:\n",
    "  -h\n",
    "\tPrint help detailed help screen\n",
    "  -V\n",
    "\tPrint version information\n",
    "  -H STRING\n",
    "\tDotted decimal IP address or fully qualified domain name of host\n",
    "  -p INTEGER\n",
    "\tUDP port number for SNMP access (default: 161)\n",
    "  -s STRING\n",
    "\tSNMP community string for host (default: public)\n",
    "  -w INTEGER\n",
    "\tExit with WARNING if less than INTEGER units are free\n",
    "  -w PERCENT%\n",
    "\tExit with WARNING if more than PERCENT is used (default: 85%)\n",
    "  -c INTEGER\n",
    "\tExit with CRITICAL if less than INTEGER units are free\n",
    "  -c PERCENT%\n",
    "\tExit with CRITICAL if more than PERCENT is used (default: 90%)\n",
    "  -u STRING\n",
    "\tChoose units: KB, MB, GB or (default: MB)\n",
    "  -d INTEGER\n",
    "\tSNMP index of device to check\n",
    "  -d STRING\n",
    "\tSNMP description of device to check (e.g. /var)\n",
  "\n";

  print	"Examples:\n",
    "  $PROGNAME -H 10.0.2.8 -s mycommunity -w 85% -c 90% -d /var\n",
    "  # Checks space used on /var, warning at 85%, critical at 90%\n\n",
    "  $PROGNAME -H 10.0.2.8 -s mycommunity -w 90% -c 95% -d C\n",
    "  # Checks space used on C:\\ drive, warning at 90%, critical at 95%\n\n",
    "  $PROGNAME -H 10.0.2.8 -s mycommunity -w 1024 -c 512 -d virt\n",
    "  # Checks free \"Virtual Memory\", warning at 1GB, critical at 512MB\n\n",
    "  $PROGNAME -H 10.0.2.8 -s mycommunity\n",
    "  # Gives a table listing of devices available via SNMP\n\n",
  "\n";
}

sub croak (;$) {
###
### -- display error message and exit

  print "$_\n" if $_ = shift; exit $ERRORS{'UNKNOWN'};
}

sub shift_argv ($) {
###
### -- get next command line argument
  
  my $opt	= shift(@_) || return;
  my $arg	= shift(@ARGV);
  
  return $arg if defined($arg);
  croak("CONFIG: missing argument for option: -${opt}");
}

sub commify ($) {
###
### -- pretty print numbers as from the perl cookbook

  my $num	= shift;
  $num		= reverse(sprintf('%u', $num));
  $num		=~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;

  scalar reverse $num;
}

sub lookup_desc ($;$) {
###
### -- lookup snmp device index by description

  my $snmp	= shift || return;
  my $desc	= shift || q{};
  my $query	= join('.', $OID_BASE, '3');
  my $resp	= $snmp->get_table($query);
  my $index	= q{};
  my $letter	= q{};
  my %table	= ();

  if (!defined($resp)) {
    croak('SNMP query failed');
  }
  if ($desc =~ /^[A-Za-z]$/o) {				## - drive letter?
    $letter	= uc($desc);
    if ($VERBOSE) {
      print "Looking for \"${letter}:\\\" drive\n";
    }
  }
  if ($VERBOSE && $desc && !$letter) {
    print "Finding index for \"$desc\"\n";
  }

  foreach (keys %$resp) {
    $index	= substr($_, length($query) + 1);
    if ($VERBOSE > 1) {
      print "devDesc $_ => $resp->{$_}\n";
    }
    if (!$desc) {					## - device table list?
      $table{$index} = $resp->{$_};
      next;
    }
    if ($resp->{$_} eq $desc) {				## - device desc match?
      if ($VERBOSE) {
	print "Matched \"$desc\" as index $index\n";
      }
      return $index;
    }
    next unless $letter;
    if ($resp->{$_} =~ /^${letter}:\\/) {		## - drive letter match?
      if ($VERBOSE) {
	print "Matched \"${letter}:\\\" drive as index $index\n";
      }
      return $index;
    }
  }

  if (! $desc) {
    print "\nIndex\tDescription\n=====\t===========\n";
    foreach (sort {$a <=> $b} (keys %table)) {
      print "$_\t$table{$_}\n";
    }
    croak();
  }
  croak("lookup device-id failed: ${desc}");
}

### parse and qualify arguments
###--------------------------------------------------------------------------###

if ($#ARGV == -1) {
  print_usage();
  croak();
}
while($_ = shift(@ARGV)){	
  if ($_ !~ s/^\-//o) {unshift(@ARGV, $_); last}	## - well formed arg?
  if ($_ eq "H") {$host		= shift_argv($_); next}
  if ($_ eq "p") {$port		= shift_argv($_); next}
  if ($_ eq "s") {$comm		= shift_argv($_); next}
  if ($_ eq "w") {$warn		= shift_argv($_); next}
  if ($_ eq "c") {$crit		= shift_argv($_); next}
  if ($_ eq "v") {$VERBOSE++;      next}
  if ($_ eq "V") {print_version(); croak()}
  if ($_ eq "h") {print_help();	   croak()}
  if ($_ eq "d") {
    $desc	= shift_argv($_) || q{};
    $desc	= $desc	eq 'real' ? 'Real Memory'	:
		  $desc eq 'phys' ? 'Physical Memory'	:
		  $desc eq 'swap' ? 'Swap Space'	:
		  $desc eq 'virt' ? 'Virtual Memory'	:
		  $desc;
    next;
  }
  if ($_ eq "u") {
    $unit_desc	= shift_argv($_) || q{};
    $unit_desc	= uc($unit_desc);
    if (defined($unit_t{$unit_desc})) {
      $unit_sz	= $unit_t{$unit_desc};
      next;
    }
    croak("unit type $unit_desc not known");
  }
  croak("CONFIG: unknown option -${_}");
}
if ($port !~ /^[0-9]+$/o || $port < 1 || $port > 65535) {
  croak("CONFIG: invalid port number: ${port}");
}
if (! $host)			{croak("CONFIG: missing host address")}
if (! inet_aton($host))		{croak("CONFIG: bad host address: ${host}")}
if ($VERBOSE)			{print "\n"}

### create snmp object
###--------------------------------------------------------------------------###

$snmp		= Net::SNMP->session(
  -hostname	=> $host,
  -port		=> $port,
  -community	=> $comm,
  -timeout	=> int(($TIMEOUT / 3) + 1),
  -retries	=> 2,
  -version	=> 1,
  -nonblocking	=> 0x0
);
if ($VERBOSE) {
  print "HOST\t$host\nPORT\t$port\nCOMM\t$comm\n";
}
if (!defined($snmp)) {
  croak("create snmp session failed: ${!}")
}
if ($desc =~ /^[0-9]+$/o) {
  $index	= $desc;
}
else {
  $index	= lookup_desc($snmp, $desc);
}

### create snmp query
###--------------------------------------------------------------------------###

$devDesc	= join('.', $OID_BASE, '3', $index);
$devUnit	= join('.', $OID_BASE, '4', $index);
$devSize	= join('.', $OID_BASE, '5', $index);
$devUsed	= join('.', $OID_BASE, '6', $index);
if ($VERBOSE) {
  print "Getting information for hrStorage.${index}\n";
}
$resp		= $snmp->get_request(
  -varbindlist => [$devDesc, $devUnit, $devSize, $devUsed]
);
$snmp->close();

croak("SNMP query failed for device-id: ${index}") if ! defined($resp);
croak("No size returned for device-id: ${index}") if $resp->{$devSize} < 1;
if ($VERBOSE > 1) {
  print "devDesc $devDesc => $resp->{$devDesc}\n",
		"devSize $devSize => $resp->{$devSize}\n",
		"devUsed $devUsed => $resp->{$devUsed}\n",
		"devUnit $devUnit => $resp->{$devUnit}\n"
		;
}
if ($VERBOSE) {
  print "\n";
}

### process snmp response
###--------------------------------------------------------------------------###

$unit_sz	= $unit_sz / $resp->{$devUnit};
$perc		= int(($resp->{$devUsed} / $resp->{$devSize}) * 100);
$size		= sprintf("%0.2f", $resp->{$devSize} / $unit_sz);
$free		= sprintf("%0.2f",
  ($resp->{$devSize} - $resp->{$devUsed}) / $unit_sz
);

if ($warn =~ /\%$/o || $crit =~ /\%$/o) {
  $warn		=~ s/%$//;
  $crit		=~ s/%$//;
  $state	= $perc >= $crit ? 'CRITICAL' :
		  $perc >= $warn ? 'WARNING'  :
		  'OK';
}
else {
  $state	= $free <= $crit ? 'CRITICAL' :
		  $free <= $warn ? 'WARNING'  :
		  'OK';
}

if ($free >= 100) {$free = commify(int($free))}
if ($size >= 100) {$size = commify(int($size))}

print	"SNMP $state - ",
	"$resp->{$devDesc} at ${perc}% with $free of $size $unit_desc free\n";

exit $ERRORS{$state};

### -- EOF
