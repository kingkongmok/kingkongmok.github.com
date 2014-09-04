#!/usr/bin/perl -w
use strict;
use HTML::Template;
my $template = HTML::Template->new(filename => "library.html");
$template->param(
name => "Paul Fenwick",
title => "Programming Perl, 3rd Ed",
author => "Larry Wall, Tom Christiansen and Jon Orwant",
duedate => "next Wednesday",
fine => 2.20,
timeperiod => "week"
);
print "Content-Type: text/html\n\n",$template->output;

