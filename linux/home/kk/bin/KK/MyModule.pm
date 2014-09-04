#
#===============================================================================
#
#         FILE: MyModule.pm
#
#  DESCRIPTION: http://www.perlmonks.org/?node_id=102347
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 11/25/2013 04:42:13 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
 
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(func1 func2);
%EXPORT_TAGS = ( DEFAULT => [qw(&func1)],
                 Both    => [qw(&func1 &func2)]);

sub func1  { return reverse @_  }
sub func2  { return map{ uc }@_ }

1;
