#!/usr/bin/perl
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./downloadNovel.pl
#
#  DESCRIPTION: 下载小说的,第一个<STDIN>输入http://book.easou.com/c/index.m\
#   的第一章的路径,第二个<STDIN>输入要OUTOUTFILENAME。
#
#      OPTIONS: ---
# REQUIREMENTS: Mojo::UserAgent
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 02/19/2014 02:47:01 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

#!/usr/local/bin/perl
use strict;
use Mojo::UserAgent;

print '_'x80,"\n"," "x35,"EaSou Tool\n",
    'http://book.easou.com/c/index.m',"\n"
    ,'-'x80,"\nStart Link: ";
chomp (my $newUrl=<STDIN>);
print "Out FileName: ";
chomp (my $out_file=<STDIN>);

my $time=time;
my $baseUrl='http://book.easou.com';
my $page=0;
my $count=0;
open OF,">$out_file" || die "$!\n";

$|=1;
use utf8;
binmode(OF, ':encoding(utf8)');
select OF;
$|=1;
select STDOUT;

my $ua=Mojo::UserAgent->new;
#$ua=$ua->name('Mozilla/4.0 (compatible; MSIE 5.12; Mac_PowerPC)');
#$ua=$ua->max_redirects(1);
#$ua=$ua->http_proxy('http://llc:123456@168.1.6.143:9999') if $ARGV[0] eq 'p';


my $callback;$callback=sub{
    my($ua,$tx)=@_;

    unless($tx->success){
        $count++;
        print "\n\@$page GET Page FAIL!\n";
        if ($count<3) {
            print "Retry... ($count)\n";
            $ua->get($newUrl=>$callback);
            next;
            
        }else{
            die "\n\nEnd Link:    " . $newUrl . "\n";
        }
    }
    $count=0;
    $page++;
    print "Page_No: $page   \tTime: ",time-$time, "s\n";
    
    my $dom=$tx->res->dom->at('div#block11');
    unless ($dom->at('p#block1131')->all_text =~ m/下章/) {
        print "\nEND OF THE BOOK!\n";
        return;
    }
    $newUrl=$dom->at('p#block1131')->at('a')->attr('href');
    $newUrl=$baseUrl . $newUrl;
    $ua->get($newUrl=>$callback);
    
    my $title=$dom->at('p#block1141')->all_text;
    print OF "$title\n\n";
    my $content=$dom->at('div#block1142');
    $content=~s/<div.*?>//o;
    $content=~s!</div>$!!o;
    $content=~s!<br />!\n!go;
    $content=~s!&quot;!"!go;
    
    print OF "$content\n\n";
};

$ua->get($newUrl=>$callback);
Mojo::IOLoop->start;
