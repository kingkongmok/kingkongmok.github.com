=head1 NAME
Author:shallow
input file example:
202.40.144.0
202.40.150.0
202.40.155.0
202.40.158.0
202.40.162.0
=cut
use Data::Dumper;
use AnyEvent::HTTP;
use EV;
use utf8;
use Encode;
@ip138_ip=(
    '61.140.13.80',
    '61.140.13.81',
    '61.140.13.85',
    '61.140.13.87',
    '183.61.67.25',
    '183.61.67.24',
    '183.61.67.27',
    '183.61.67.26',
);

my $file = $ARGV[0];
open(FILE,"<",$file)||die"cannot open the file: $!\n";
@linelist=<FILE>;
@iplist;
foreach $eachline(@linelist)
{
    $eachline=~s/[\r\n]//g;	
    push @iplist,$eachline;
}
close FILE;

$key='<td align="center"><ul class="ul1"><li>(.*?)\<';
map
{
    getipinfo($_);
    sleep 0.01;
}@iplist;

sub getipinfo
{
    my ($ip)=@_;
    $num=int(rand(scalar(@ip138_ip)));
    my $url = 'http://'.@ip138_ip[$num].'/ips138.asp?ip='.$ip.'&action=2';#www.ip138.com
    #print "get:",$url,"\n";
    http_get $url,
    headers => 
    {
        HOST => 'www.ip138.com',
        User-Agent => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.1.2503.125',
        'Referer' => 'http://www.ip138.com/'
    },
    sub
    {
        my ($html, $hdr) = @_;	
        if ( ($hdr->{Status} == '200')) 
        {

            @personal=split(/\n/,$html);  
            map
            {
                $str=encode("utf8",decode("gbk",$_)); 
                if($str=~/$key/)
                {
                    $str=sprintf("%-16s:%s",$ip,$1);
                    print "$str";
                }
            }@personal;
            #print Dumper @personal;
            print "\n";
        }
        else
        {
            print "$ip: error status:",$hdr->{Status},"\n";
        }
    };
}


print "run...\n";
EV::run; 
