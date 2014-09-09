#!/usr/bin/perl
#===============================================================================
#
#         FILE: cgi_example.pl
#
#        USAGE: 
#
#  DESCRIPTION: cgi tab example from perl develop.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kingkong Mok (), kingkongmok AT gmail DOT com
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 10/17/2013 11:53:05 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


    use CGI;
    # use CGI::Carp qw(fatalsToBrowser); # Uncomment for debugging

    my $q = new CGI;

    print $q->header;

    my $style = get_style();

    print $q->start_html(
        -title => "An example web page",
        -style => {-code => $style},
    );

    print $q->h2("Grandma's Lemon Cordial");

    print $q->p("Lots of Experience - I've made it once before!");

    print $q->h4("Ingredients");

    print $q->ul(
        $q->li(['water', 'sugar', 'lemon juice']),
    );

    print $q->h4("Nutrition Information");

    print $q->table(
        {-cellpadding => 3},
        $q->Tr($q->th(['Per', 'Serving', '100mL'])),
        $q->Tr($q->td(['Energy', '333kj', '133kj'])),
        $q->Tr($q->td(['Protein', '<1g', '<1g'])),
        $q->Tr($q->td(['Fat -total', '<1g', '<1g'])),
        $q->Tr($q->td(['-saturated', '<1g', '<1g'])),
        $q->Tr($q->td(['Carbohydrate -total', '15g', '6g'])),
        $q->Tr($q->td(['-sugars', '15g', '6g'])),
        $q->Tr($q->td(['sodium', '35mg', '14mg'])),
    );

    print $q->end_html;

    exit 0;
    #-------------------------------------------------------------

    sub get_style {
        my $style = "
        body {
            font-family: verdana, arial, sans-serif;
            bgcolor: white;
        padding-left: 5%;
        }
        H2 {
            color: green;
            border-bottom: 1pt solid;
        }
        H4 {
            color: darkgreen;
        }
        p {
            font-variant: small-caps;
            font-weight: bold;
        }
        table {
            border: darkgreen 1pt solid;
        }
        th,td {
            border: green 1pt dashed;
        }
    "
    }

    #-------------------------------------------------------------
