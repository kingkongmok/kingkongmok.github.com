#!/usr/bin/perl
use strict; 
use warnings;
use File::Path;
use MIME::Lite;
use DBI;

my $path = './graph';
if(-e $path) { rmtree($path); }
mkdir($path);

my $stime = `date +%Y%m%d`; chop($stime); $stime .= '1000';
if( length($stime) != 12 ) { print "Error get date"; exit; }

my $period = 86400;     #24 hour
my $width=900;
my $height=150;

my $login = 'kk';    #---in zabbix
my $pass = 'whatisup';      #---in zabbix

my $cook = "./coockfile";
my $dsn = 'DBI:mysql:zabbix:localhost';
my $db_user_name = 'zabbix';
my $db_password = 'zabbixpassword';

my $dbh = DBI->connect($dsn, $db_user_name, $db_password);
my $sth = $dbh->prepare(qq{select screenid, resourceid from  screens_items order by screenid});
$sth->execute();
my %screens;

#---get all graffics, using curl
while (my ($id, $ids) = $sth->fetchrow_array())
{
    if(length($ids) > 2){
        #print "$id => $ids\n";
        my $p = "$path/$id.$ids.png";
        my $strcomm  = `curl  -c $cook -b $cook -d "form=1&form_refresh=1&name=$login&password=$pass&enter=Enter" 127.0.0.1/zabbix/index.php`;
        $strcomm  = `curl  -c $cook -b $cook -F  "graphid=$ids" -F "period=$period" -F "stime=$stime" -F "width=$width" -F "height=$height" 127.0.0.1/zabbix/chart2.php > $p`;
    }
}

#---get user-mail and sinc by screen
my ($sendto, $exec_path);
$sth = $dbh->prepare(qq{select sendto, exec_path from media, media_type where media.mediatypeid=media_type.mediatypeid});
$sth->execute();
my %user_screen;
while (my ($sendto, $exec_path) = $sth->fetchrow_array())
{
   if(length($exec_path) > 0){
       if(!defined($user_screen{$sendto})) {  $user_screen{$sendto} = $exec_path;   } 
        else {  $user_screen{$sendto} .= ":$exec_path"; }   
    }
}
$sth->finish();
    
#---get name report
my ($id, $report);
$sth = $dbh->prepare(qq{select screenid, name from screens;});
$sth->execute();    
my %name_report;
while (my ($id, $report) = $sth->fetchrow_array()){
    $name_report{$report} = $id;
}
$sth->finish();

$dbh->disconnect();

#---send mail for all users
while(my ($user,$screens) = each %user_screen){
    my $msg = MIME::Lite->new(
                               From    => 'zabbix@ins14.datlet.com+',
                               To      => $user,
                               Subject => 'Zabbix Report',
                               Type    => 'multipart/related' );
    my $str="<body>\n";

    my @massend = split(/:/,$screens);
    my @files = glob($path.'/*');
        
#---get all html
    foreach my $mid (@massend)
    {            
        if(defined($name_report{$mid})) {
            $str .= "<br>\n<H1 ALIGN=\"center\">$mid</H1>\n";
        }
        else    {   next;   }
        
        my $i=0;
        foreach my $file (@files){
            if( $file =~ /(\/$name_report{$mid}\.)/ )
            {
                $str .="<br>\n<div align=\"center\"><img src=\"cid:$name_report{$mid}.$i.png\"></div>\n";
                $i++;
            }
                
        }
    }
    $str .= "</body>\n";
        #print $str."\n";
        
#---attach html
    $msg->attach( Type => 'text/html; charset= utf-8',#windows-1251',
                     Data => $str );
        
#---attach files
    foreach my $mid (@massend)
    {            
        if(defined($name_report{$mid})) {  }
        else { next; }
            
        my $i=0;
        foreach my $file (@files){
            if( $file =~ /(\/$name_report{$mid}\.)/ )
            {
                $msg->attach( Type        => 'image/png',
                              Path        => $file,
                              Id          => "$name_report{$mid}.$i.png");
                        #print "$name_report{$mid}.$i.png   =>   $file\n";
                $i++;
                    
            }       
        }
    }
                
    $msg->send();
}

exit ;
