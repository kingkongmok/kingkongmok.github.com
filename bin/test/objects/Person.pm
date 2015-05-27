#!/usr/bin/perl 

package Person;

sub new
{
    my $invocant = shift;
    print "invocant is $invocant\n";
    my $class = ref($invocant) || $invocant;
    print "class is $class\n" ;
    my $self = {
        _firstName => shift,
        _lastName  => shift,
        _ssn       => shift,
    };
    # Print all the values just for clarification.
    # print "First Name is $self->{_firstName}\n";
    # print "Last Name is $self->{_lastName}\n";
    # print "SSN is $self->{_ssn}\n";
    bless $self, $class;
    return $self;
}
sub setFirstName {
    my ( $self, $firstName ) = @_;
    $self->{_firstName} = $firstName if defined($firstName);
    return $self->{_firstName};
}

sub getFirstName {
    my( $self ) = @_;
    return $self->{_firstName};
}
1;
