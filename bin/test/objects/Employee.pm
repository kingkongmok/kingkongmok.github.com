#!/usr/bin/perl

package Employee;
use Person;
use strict;
our @ISA = qw(Person);    # inherits from Person


# sub new {
#     my ($class) = @_;
#     # Call the constructor of the parent class, Person.
#     my $self = $class->SUPER::new( $_[1], $_[2], $_[3] );
#     # Add few more attributes
#     $self->{_id}   = undef;
#     $self->{_title} = undef;
#     bless $self, $class;
#     return $self;
# }

# Add more methods
sub setLastName{
    my ( $self, $lastName ) = @_;
    $self->{_lastName} = $lastName if defined($lastName);
    return $self->{_lastName};
}

sub getLastName {
    my( $self ) = @_;
    return $self->{_lastName};
}

1
