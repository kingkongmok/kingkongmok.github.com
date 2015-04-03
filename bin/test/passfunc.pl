#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 10/12/2013 11:23:24 AM
#     REVISION: ---
#===============================================================================

use strict ;
use warnings ;

sub   passfunc($$){
  my $para=shift;
  my $code=shift;
  my @out=$code->($para);
}

my $handle = sub { 
 my $para=shift;
  my @out=map { s/http/ftp/g; $_} @$para;
};
 
my @data=('http://www.baidu.com','http://www.google.com');
my @out=passfunc(\@data,$handle);
 
print join("\n",@out);

