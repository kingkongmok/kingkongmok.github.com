#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: email_report_check.pl
#
#        USAGE: ./email_report_check.pl  
#
#  DESCRIPTION: list NOT FOUND email
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: list error message. null if success.
#       AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
# ORGANIZATION: datlet.com
#      VERSION: 1.0
#      CREATED: 06/26/2017 03:21:21 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
# use utf8;
use Data::Dumper;
use feature 'say';
use POSIX;
use Fcntl 'O_RDONLY';
use Tie::File;
use Getopt::Std;


#-------------------------------------------------------------------------------
#  usage
#-------------------------------------------------------------------------------
getopts('mqht');
our($opt_m, $opt_q, $opt_h, $opt_t);

sub usage {
    print <<HELPTEXT;                                                           

    目的： 查找遗漏的邮件
    

    参数：
            -t          测试，输出共找到多少个邮件
            -h          print this help                      

HELPTEXT
}


#-------------------------------------------------------------------------------
#  昨天
#-------------------------------------------------------------------------------
my $yesterday_date = strftime "%F", localtime time - 24*60*60 ;
my $yesterday_ymd = strftime "%Y%m%d", localtime time - 24*60*60 ;
#-------------------------------------------------------------------------------
#  前天
#-------------------------------------------------------------------------------
my $before_yesterday_date = strftime "%F", localtime time - 2*24*60*60 ;
#-------------------------------------------------------------------------------
#  如果出现邮件名相同，必须列出不同的收件人，
#  recipients as key of hash, exclusive
#  注意，添加时，应该确保收信人和上面这些key不同
#-------------------------------------------------------------------------------
my %headers_Rec_Sub = (
    'wayne.cai-hsf@cks.com.hk' => "The DOR Report $yesterday_ymd",
    'ken.lau-hsf@cks.com.hk' => "$yesterday_date SRC2 Point Payment Report",
    'alex.wong@venetian.com.mo' =>
    "$yesterday_date CotaiJet Onboard Passenger Report.xls",
    'Gary.xu@venetian.com.cn' =>
    "$before_yesterday_date SRC2 Cash Payment Report",
    'benson.ho@sands.com.mo' =>
    "$yesterday_date- CotaiJet Flash Report Netrevenue.xlsx",
    'Christy.cheung-hsf@cks.com.hk' =>
    "$yesterday_date- CotaiJet Flash Report Netrevenue.xlsx",
);


#-------------------------------------------------------------------------------
#  列出itdept的inbox位置， default
#  /mnt/172.16.45.203/IceWarp/mail/cks.com.hk/itdept/inbox   
#-------------------------------------------------------------------------------
#my $mail_location = "/tmp/mail/";
my $mail_location = "/mnt/172.16.45.203/IceWarp/mail/cks.com.hk/itdept/inbox/";


#===  FUNCTION  ================================================================
#         NAME: matchReg
#      PURPOSE: check the mail header if contains both recipients and subject
#   PARAMETERS: $string, $recipients, $subject
#      RETURNS: 0/1
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub matchReg {
    my $string = shift;
    my $recipients = shift;
    my $subject = shift;
    if ( $string =~ m/^To:.*?$recipients.*?^Subject: $subject/smg ) {
        return 1;
    } else {
        return 0;
    }
}


#===  FUNCTION  ================================================================
#         NAME: getContent
#      PURPOSE: 列出邮件的前20行，一般这个就能得到邮件信息
#   PARAMETERS: $filename 邮件路径
#      RETURNS: $string 20行内容
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub getContent {
    my $filename = shift;
    my @lines;
    if (  -r $filename ) {
#-------------------------------------------------------------------------------
#  只读
#-------------------------------------------------------------------------------
        tie @lines, 'Tie::File', $filename , mode =>"O_RDONLY" || die $!;
    }
    return @lines ? join "\n",@lines[0..19] : undef;
}


#===  FUNCTION  ================================================================
#         NAME: find_email_file
#      PURPOSE: 查找昨天的邮件实现 find . -type f -mtime -1 功能
#   PARAMETERS: $dir, $filename
#      RETURNS: @files
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub find_email_file () {
	use strict;
	use Data::Dumper;
	use File::Find::Rule;
	my $dir = shift;
	my $filename = shift;
#-------------------------------------------------------------------------------
#  查找昨天的，所以是24小时前的文件
#-------------------------------------------------------------------------------
	my $last_day = time()-24*60*60;
	my @files = File::Find::Rule->file()
	->name($filename)
	->mtime(">$last_day")
	->in($dir);
	return @files;
}


#-------------------------------------------------------------------------------
#  main
#-------------------------------------------------------------------------------
sub listNoutFound{
    my @files = &find_email_file($mail_location, "*.imap", );
    foreach my $recipients ( keys %headers_Rec_Sub ) {
        my $match;
        foreach my $file ( @files ) {
            my $content = &getContent($file);
            $match = &matchReg($content, $recipients,
                $headers_Rec_Sub{$recipients});
            if ( $match ) {
                if ( $opt_t ) {
                    say "$recipients\n",
                    "\t$headers_Rec_Sub{$recipients} MATCH ON $file";
                }
                last;
            }
        }
        say "\"$headers_Rec_Sub{$recipients}\" 未能找到，请确认" unless $match;
    }
}


if ( $opt_h)
{
    &usage;
    exit;
}


&listNoutFound
