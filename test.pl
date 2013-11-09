#!/usr/bin/env perl

=head1 [progam_name]

 description:

=cut

use feature ':5.10';
use strict;
use Getopt::Long;

my $prog = $0;
my $usage = <<EOQ;
Usage for $0:

  >$prog [-test -help -verbose]

EOQ

my $help;
my $test;
my $debug;
my $verbose =1;


my $ok = GetOptions(
                    'test'      => \$test,
                    'debug:i'   => \$debug,
                    'verbose:i' => \$verbose,
                    'help'      => \$help,
                   );

if ($help || !$ok ) {
    print $usage;
    exit;
}


print template();


sub template {
    ##
    ### Here start the template code
    ##
    return <<'EOT';
#!/usr/bin/env perl

=head1 [progam_name]

 description: This script prints a template for new perl scripts

=cut

use feature ':5.10';
use strict;
#use warnings;
#use Data::Dumper;
use Getopt::Long;
# use Template;
# use PMG::PMGBase;  
# use File::Temp qw/ tempfile tempdir /;
# use File::Slurp;
# use File::Copy;
# use File::Path;
# use File::Spec;
# use File::Basename qw(basename dirname);
# use List::Util qw(reduce max min);
# use List::MoreUtils qw(uniq indexes each_arrayref natatime);

# my $PMGbase = PMG::PMGBase->new();
my $prog = $0;
my $usage = <<EOQ;
Usage for $0:

  >$prog [-test -help -verbose]

EOQ

my $date = get_date();

my $help;
my $test;
my $debug;
my $verbose =1;

my $bsub;
my $log;
my $stdout;
my $stdin;
my $run;
my $dry_run;

my $ok = GetOptions(
                    'test'      => \$test,
                    'debug:i'   => \$debug,
                    'verbose:i' => \$verbose,
                    'help'      => \$help,
                    'log'       => \$log,
                    'bsub'      => \$bsub,
                    'stdout'    => \$stdout,
                    'stdin'     => \$stdin,

                    'run'       => \$run,
                    'dry_run'   => \$dry_run,

                   );

if ($help || !$ok ) {
    print $usage;
    exit;
}

sub get_date {

    my ($day, $mon, $year) = (localtime)[3..5] ;

    return my $date= sprintf "%04d-%02d-%02d", $year+1900, $mon+1, $day;
}

sub parse_csv_args {

    my $csv_str =shift;
    return [split ',', $csv_str];
}

EOT


}
