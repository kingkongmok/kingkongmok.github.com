#!/usr/bin/env perl

use warnings;
use strict;
use MyCGI;

my $page = MyCGI->new();
print
    $page->header(),
    $page->start_html('My home page'),
    $page->page_header(),
    $page->content('My own content'),
    $page->page_footer(),
    $page->end_html();
