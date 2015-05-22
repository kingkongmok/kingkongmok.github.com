package Critter;
   # sub spawn { my $class = shift ; my $self = {} ; bless { $self, $class } ; return $self}
   # sub spawn ($@) { 
   #     my $scalar = shift ;
   #     # my $class = shift ;
   #     my $self = {} ;
   #     bless $self, "$scalar"; 
   #     return $self;
   #  }

   sub new {
       my $self = { "wish" => 1 };
       bless $self ; 
       return $self; 
   }

1
