#!/usr/bin/perl

package Some::Module;  # assumes Some/Module.pm
use strict;
use warnings;

BEGIN {
    require Exporter;
    # set the version for version checking
    our $VERSION     = 1.00;
    # Inherit from Exporter to export functions and variables
    our @ISA         = qw(Exporter);
    # Functions and variables which are exported by default
    our @EXPORT      = qw(func1 func2);
    # Functions and variables which can be optionally exported
    our @EXPORT_OK   = qw($Var1 %Hashit func3);
}

# exported package globals go here
our $Var1    = '';
our %Hashit  = ();
# non-exported package globals go here
# (they are still accessible as $Some::Module::stuff)
our @more    = ();
our $stuff   = '';
# file-private lexicals go here, before any functions which use them
my $priv_var    = '';
my %secret_hash = ();
# here's a file-private function as a closure,
# callable as $priv_func->();
my $priv_func = sub {
};
# make all your functions, whether exported or not;
# remember to put something interesting in the {} stubs
sub func1      { }
sub func2      {}
# this one isn't exported, but could be called directly
# as Some::Module::func3()
sub func3      {  }
END {  }       # module clean-up code here (global destructor)

1;  # don't forget to return a true value from the file
