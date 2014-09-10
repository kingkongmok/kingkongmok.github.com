#!/usr/bin/perl
#===============================================================================
#
#         FILE: transfterDropboxGPG.pl
#
#        USAGE: ./transfterDropboxGPG.pl FILENAME
#
#  DESCRIPTION: transfer files from dropbox with gpg encrypts.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 03/26/2014 04:27:31 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use File::Basename ;
use File::Spec;
use lib '/home/kk/bin';
use KK::Gpgutil ;
use KK::Dropboxutil ;
use Getopt::Std;


my %gpgVaris = (
    gpgUser=>'kingkongmok@gmail.com'
#    gpgUser=>'kk_blog'
);

&transfer ;
sub transfer {
    if ( @ARGV ) {
        my ( $file ) = @ARGV ;
        if ( -f $file ) {
            if ( -r $file ) {

                # rel2abs Converts a relative path to an absolute path .
                my $filename = File::Spec->rel2abs($file);
                my ($name,$path,$suffix) = fileparse($filename, qr/\.[^.]*/);

                # if file.asc, decrypt it, if not file.asc, encrypt it.
                if ( $suffix eq '.asc' ) {
                    my $outputfile = dismissDropboxLocation($filename);
                    decrypt($filename, $outputfile, \%gpgVaris);
                }
                else {
                my $outputfile = addDropboxLocation($filename) ;
                    encrypt($filename, $outputfile, \%gpgVaris) ;
                }
            }
        }
        else {
            my %opts ;
            getopts('c', \%opts); 
            if ( $opts{c} ) {
                &checkNewerFile;
            }
            else {
                print qq#$file not found.\n#
            }
            
        }
    }
    else {
        #print qq#usage: $ENV{_} FILENAME\n# , qq#\t$ENV{_} -a  TO CHECKNEWFILE#;
        &usage ;
    }
} ## --- end sub transfer

sub checkNewerFile {
    my	( $par1 )	= @_;
    my %hashFiles = &checkDropboxUpdateFile;
        
    while ( my ($ascFile, $localFile) = each %hashFiles ) {
        
        if ( -e $localFile ) {
            if ( +(stat($localFile))[9] < +(stat($ascFile))[9] ) {
                print "dropbox \"$ascFile\" is newer, ",
                "pull it?<y/[N]>\n";
                chomp(my $ifcopy = <STDIN>);
                if ( $ifcopy eq 'y' ) {
                    decrypt($ascFile, $localFile, \%gpgVaris);
                }
            }
            else {
                print "local file \"$localFile\" is newer, ",
                "push it?<y/[N]>\n";
                chomp(my $ifcopy = <STDIN>);
                if ( $ifcopy eq 'y' ) {
                    encrypt($localFile, $ascFile, \%gpgVaris);
                }
            }
            
        }
        else {
            print "local file \"$localFile\" is not exists.\n";  
            decrypt($ascFile, $localFile, \%gpgVaris);
                print "file \"$ascFile\" is merged, ",
                "delete it?<y/[N]>\n";
                chomp(my $ifcopy = <STDIN>);
                if ( $ifcopy eq 'y' ) {
                    unlink $ascFile;
                }
        }
    }


    return ;
} ## --- end sub checkNewerFile

sub usage {
my $usageMessage = <<END;
usage: $ENV{_} [OPTIONS] [FILENAME]
    opts: 
        -c    check newer file.
END
;
    print $usageMessage ;
} ## --- end sub usage
    
