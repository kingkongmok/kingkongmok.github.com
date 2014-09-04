use strict;
use warnings;
#use File::Copy;
use File::Copy::Recursive qw/rmove/;

#===  FUNCTION  ================================================================
#         NAME: decrypt
#      PURPOSE: decrypt inputfile to ouputfile with gpg user $gpgVaris->{gpgUser} 
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub decrypt($$%) {
    my	( $inputfile, $outputfile , $gpgVaris )	= @_;
    my $gpgUser = $gpgVaris->{gpgUser} ;
    my $gpgCommand = "/usr/bin/gpg -u '$gpgUser' -d '$inputfile' > '$outputfile'";

    #save to outputfile.
#    open ( my $filehandle, ">", $outputfile ) or die "$!";
#    print $filehandle system('/usr/bin/gpg -u $gpgUser -d "$inputfile"'); 
#    close $filehandle;

    system($gpgCommand);
    print "$outputfile saved\n";

} ## --- end sub decrypt

#===  FUNCTION  ================================================================
#         NAME: encrypt
#      PURPOSE: encrypt inputfile to outputfile with gpg user.
#   PARAMETERS: ????
#      RETURNS: ????
#  DESCRIPTION: ????
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub encrypt($$%) {
    my	( $inputfile , $outputfile , $gpgVaris)	= @_;
    my $gpgUser = $gpgVaris->{gpgUser};
    my $ascFilename = $inputfile . ".asc" ;
    qx#/usr/bin/gpg -ea -r $gpgUser "$inputfile"#; 

    #File::Copy::Recursive->rmove() will make parent directories as needed.
    rmove($ascFilename,$outputfile) || die $!;
    print "$outputfile saved\n";
    
} ## --- end sub decrypt

1;
