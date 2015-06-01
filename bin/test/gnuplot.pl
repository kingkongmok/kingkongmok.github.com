use strict;
use warnings;
use Chart::Gnuplot;

my $chart = Chart::Gnuplot->new(
    output => '/home/kk/Downloads/test.png',
    terminal => 'png',
    key => 'top left',
    title => {
        text => 'title here',
        font => "DejaVuSansMono, 40",
    },
);

my $dataset = Chart::Gnuplot::DataSet->new(
    func => "sin(x)",
);
my $dataset2 = Chart::Gnuplot::DataSet->new(
    func => "cos(x)",
);

$chart->plot2d($dataset, $dataset2);

        # set key top left title "TotalMaxValue=$maxValue(PV) at $maxTime"
        # set title "$yesterday 2XX minutely" font "/usr/share/fonts/dejavu-lgc/DejaVuLGCSansMono-Bold.ttf, 20"
        # set xdata time
        # set timefmt "%H:%M"
        # set format x "%H:%M"
        # set grid
        # set xtics rotate
        # set yrange [0:] noreverse
        # set xlabel 'Time: every minute'
        # set ylabel 'Http 2XX stat code'
        # set terminal png giant size 1000,500 
        # set output "/tmp/tomcat200.png"
        # plot "$N" using 1:2 title '$serverList[0]' with lines linecolor rgb "red" linewidth 1.5,\\
