use strict;
use warnings;
use Chart::Gnuplot;

my $chart = Chart::Gnuplot->new(
    output => '/home/kk/Downloads/test.png',
    terminal => 'png',
    imagesize => "1000,500", 
    key => 'top left',
    title => {
        text => 'nginx status',
        font => "Bitstream Vera Sans Mono, 40",
    },
    grid => 'on',
    # timeaxis => "x",
    xlabel => 'Time: every minute',
    yrange => [0, "*"],
    ylabel => 'nginx request',
);



# Prepare data to plot
my @x = (1 .. 7);
my @pt = ();

for (my $i = 0; $i < @x; $i++)
{
    my $y = sqrt($x[$i]) + 1.5*(rand()-0.5);
    my $s = rand();

    push(@pt, [$x[$i], $y, $s])
}
# DataSet object
my $data = Chart::Gnuplot::DataSet->new(
    points => \@pt,
    style  => "yerrorbars",
    color  => "#DD8888",
    width  => 4,
);

# Time array
# my @x = qw(
#     00:00:00
#     03:05:24
#     06:15:58
#     10:03:20
#     10:57:00
#     11:42:32
#     13:30:03
#     15:00:30
#     17:23:27
#     19:38:41
# );
# my @y = (1 .. 10);
# my @z = (6 .. 15);
#
# my $dataset = Chart::Gnuplot::DataSet->new(
#     xdata   => \@x,
#     ydata   => \@y,
#     color => 'green',
#     style   => 'lines',
#     title => 'y',
#     timefmt => '%H:%M:%S',      # input time format
# );
#
# my $dataset2 = Chart::Gnuplot::DataSet->new(
#     xdata   => \@x,
#     ydata   => \@z,
#     color => 'red',
#     style   => 'lines',
#     title => 'z',
#     timefmt => '%H:%M:%S',      # input time format
# );

$chart->plot2d($data);
# $chart->label(
#     text      => "Labeled at 20% from left, 25% from top",
#     fontcolor => 'blue',
#     position  => 'graph 0.2, graph 0.75'
# );

        # set key top left title "TotalMaxValue=$maxValue(PV) at $maxTime"
        # set title "$yesterday 2XX minutely" font "/usr/share/fonts/dejavu-lgc/DejaVuLGCSansMono-Bold.ttf, 20"
        # set xdata time
        # set xtics rotate
        # set terminal png giant size 1000,500 
        # set output "/tmp/tomcat200.png"
        # plot "$N" using 1:2 title '$serverList[0]' with lines linecolor rgb "red" linewidth 1.5,\\
