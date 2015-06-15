#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: tie_example_1.pl
#
#        USAGE: ./tie_example_1.pl  
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
#      CREATED: 06/08/2015 10:42:02 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

package ScalarFile;   
use Carp;      # 很好地传播错误消息。
use strict;      # 给我们自己制定一些纪律。
use warnings;      # 打开词法范围警告。
use warnings::register;   # 允许拥护说"use warnings 'ScalarFile'"。
my $count = 0;      # 捆绑了的 ScalarFile? 的内部计数。这个标准的 Carp 模块输出 carp，croak，和 confess 子过程，我们将在本


# sub TIESCALAR {      # 在 ScalarFile.pm
#         my $class = shift;
#         my $filename = shift;
#         $count++;   # 一个文件范围的词法，是类的私有部分
#         return bless \$filename, $class;
# }
#
sub TIESCALAR {   # 在 ScalarFile.pm
        my $class = shift;   
        my $filename = shift;
        my $fh;   
        if (open $fh, "<", $filename or 
        open $fh, ">", $filename)
        {
                close $fh;
                $count++;
                return bless \$filename, $class;
        }
        carp "Can't tie $filename: $!" if warnings::enabled();
        return;
}

sub    FETCH {
        my $self = shift;
        confess "I am not a class method" unless ref $self;
        return unless open my $fh, $$self;
        read($fh, my $value, -s $fh);   # NB: 不要在管道上使用 -s
        return $value;
}

sub STORE {
        my($self, $value) = @_;
        ref $self      or confess "not a class method";
        open my $fh, ">", $$self or croak "can't clobber $$self:$!";
        syswrite($fh, $value) == length $value
        or croak "can't write to $$self: $!";
        close $fh      or croak "can't close $$self:$!";
        return $value;
}

sub DESTROY {
        my $self = shift;
        confess "wrong type" unless ref $self;
        $count--;
}

1;

package main; 

tie(my $string, "ScalarFile", "/tmp/camel.lot");
$string = "Here is the first line of camel.lot\n";
$string .= "2nd line\n";



