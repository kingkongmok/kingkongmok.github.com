use strict;
use warnings;
use File::Spec;
use KK::Gpgutil ;
 
my %gpgVaris = (
    gpgUser=>'kingkongmok@gmail.com'
);


#-------------------------------------------------------------------------------
#  /path/file to /home/kk/Dropbox/path/file.asc
#-------------------------------------------------------------------------------
sub addDropboxLocation($) {
    my	( $fullname )	= @_;
    return $fullname =~ s#^#/home/kk/Dropbox#r =~ s#$#\.asc#r;
}

#-------------------------------------------------------------------------------
#  /home/kk/Dropbox/path/file.asc to /path/file
#-------------------------------------------------------------------------------
sub dismissDropboxLocation($) {
    my	( $fullname )	= @_;
    return $fullname =~ s#^/home/kk/Dropbox##r =~ s#\.asc$##r;
}

sub checkDropboxUpdateFile() {
    chomp(my @newFiles = qx#find ~/Dropbox/ -path ~/Dropbox/.dropbox -prune -o -path ~/Dropbox/Public/.dropbox -prune -o -path ~/Dropbox/.dropbox.cache -prune -o  -type f  -print# );
    my @ascFiles = grep {/\.asc$/} @newFiles ;
    my @ascStripFiles = grep {s#^/home/kk/Dropbox##} grep {s/\.asc$//} @newFiles ;
    my %hashFiles ;
    @hashFiles{ @ascFiles } = @ascStripFiles ;
    return %hashFiles ;
}
    
1;
