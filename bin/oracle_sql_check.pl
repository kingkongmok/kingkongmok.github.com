#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: oracle_sql_check.pl
#
#        USAGE: ./oracle_sql_check.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 06/06/2017 08:58:43 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
# use utf8;
use Data::Dumper;
use feature 'say';


#===  FUNCTION  ================================================================
#         NAME: getSqlResult
#      PURPOSE: 通过命令，调用sqlplus系统命令，清除空格空行
#   PARAMETERS: $
#      RETURNS: $result
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getSqlResult{
    my $command = shift; 
    chomp ( my $result = `$command` );
    $result =~ s/\s+//;
    return $result; 
}


#-------------------------------------------------------------------------------
#  sql脚本的位置
#-------------------------------------------------------------------------------
my %scripts = (
    sess_numb => '/home/kk/sql-script/active_sessions_count.sql', 
    lock_numb => '/home/kk/sql-script/get_lock_global_count.sql',
    detl20min => '/home/kk/sql-script/20min_lock.sql',
    numb20min => '/home/kk/sql-script/20min_lock_count.sql',
);


#-------------------------------------------------------------------------------
#  sql脚本名称 -> sqlplus运行的命令
#  e.g. "sqlplus -s /nolog @/home/kk/sql-script/20min_lock.sql"
#-------------------------------------------------------------------------------
my %commands = map 
{ $_ => 'sqlplus -s /nolog @' .  $scripts{$_} } 
keys %scripts; 

#-------------------------------------------------------------------------------
#  $numb20min 统计数据库有多少ctime大于20min的业务锁
#-------------------------------------------------------------------------------
my $numb20min = getSqlResult($commands{numb20min});

if ( $numb20min > 4 ) {
#-------------------------------------------------------------------------------
#  $sess_numb 统计数据库有多少个等待事务
#-------------------------------------------------------------------------------
    my $sess_numb = getSqlResult($commands{sess_numb});
#-------------------------------------------------------------------------------
#  $lock_numb 统计RAC有多少非system的锁
#-------------------------------------------------------------------------------
    my $lock_numb = getSqlResult($commands{lock_numb});
#-------------------------------------------------------------------------------
#  $detl20min 列出RAC中CTIME大于20min的锁详细信息
#-------------------------------------------------------------------------------
    my $detl20min = getSqlResult($commands{detl20min});
    print "目前RAC共有 $sess_numb 个业务等待任务。";
    print "\n";
    print "RAC共有 $lock_numb 个业务锁，其中超过20分钟的 $numb20min 个:";
    print "\n\n";
    print $detl20min;
}
else {
    print "ok";
}
