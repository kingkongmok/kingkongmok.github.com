#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: descriptive.pl
#
#        USAGE: ./descriptive.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: http://blog.csdn.net/g_r_c/article/details/11908521 统计模块
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 04/29/2015 11:02:32 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Statistics::Descriptive;  
  
my @temp=qw/26 25 23 23 26 25 24 26 28 27 26 23 28 26 25 27 27 23 24 25/;  
  


my $stat = Statistics::Descriptive::Full->new();  
$stat->add_data(\@temp);  
my $mean = $stat->mean();#平均值  
my $variance = $stat->variance();#方差  
my $num = $stat->count();#data的数目  
my $standard_deviation=$stat->standard_deviation();#标准差  
my $sum=$stat->sum();#求和  
my $min=$stat->min();#最小值  
my $mindex=$stat->mindex();#最小值的index  
my $max=$stat->max();#最大值  
my $maxdex=$stat->maxdex();#最大值的index  
my $range=$stat->sample_range();#最小值到最大值  
  
  
  
print "Number of Values = $num\n",  
      "Mean = $mean\n",  
      "Variance = $variance\n",  
      "standard_deviation = $standard_deviation\n",  
      "sum =$sum\n",  
      "min =$min\n",  
      "mindex=$mindex\n",  
      "max=$max\n",  
      "maxdex=$maxdex\n",  
      "range=$range\n";  

print "\n";
print "\n";
print "before filtered\n" ;
print join",",@temp;
print "\n";
print "after filtered\n" ;

$stat = Statistics::Descriptive::Full->new();  
$stat->add_data(\@temp);  
sub outlier_filter { return $_[1] > 0.1; }
$stat->set_outlier_filter( \&outlier_filter ); # 数据标准化排除一个数据
my @filtered_data = $stat->get_data_without_outliers();
print "we filtered index" .  $stat->_outlier_candidate_index , "\n";

print join",",@filtered_data;
print "\n";

