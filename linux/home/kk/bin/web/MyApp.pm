package MyCGI;

use warnings;
use strict;
use CGI::Carp qw/fatalsToBrowser/;
use base qw( CGI );

sub page_header {
    my $self = shift;
    return $self->div( { 'id' => 'header' },
        $self->h1('Welcome to my home page') );
}

sub page_footer {
    my $self = shift;
    return $self->div( { 'id' => 'footer' },
        $self->tt('Copyright &copy; 2010. All rights reserved.') );
}

sub content {
    my ( $self, $paragraph ) = @_;
    return $self->div( { 'id' => 'content' }, $self->p($paragraph) );
}

1;
