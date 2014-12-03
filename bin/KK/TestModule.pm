#
#===============================================================================
#
#         FILE: Test.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: KK Mok (), kingkongmok@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 12/03/2014 11:49:38 AM
#     REVISION: ---
#===============================================================================

package TestModule ; 
#sub AUTOLOAD :lvalue {no strict 'refs'; *{AUTOLOAD}}
#sub import {}

sub new {
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = {
        color => "bay",
        legs => 4,
        owner => undef,
        @_, # Override previous attributes
    };
    return bless $self, $class;
} ## --- end sub new


sub clone {
    my $model = shift;
    my $self = $model->new(%$model, @_);
    return $self; # Previously blessed by –>new
} ## --- end sub clone

sub sum {
    my $class = shift ;
    my	( $par1, $par2 )	= @_;
    return $par1+$par2;
} ## --- end sub sum

1
