
# Quarterly miles run chart, broken down by footwear.
# @author Joel Dalley
# @version 2013/Dec/24

package JBD::Tempo::Display::Chart::Quarterly::ByFootwear;

use parent 'JBD::Tempo::Display::Chart';

use JBD::Core::stern;
use JBD::Tempo::Color 'color_list';
use JBD::Tempo::Data qw(DATE FOOT);
use JSON 'to_json';


#///////////////////////////////////////////////////////////////
# Interface ////////////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart::Quarterly::ByFootwear $this
# @return hash    template replacements
sub chart {
    my $this = shift;

    my $begin_year = $this->data->begin_year;
    my $end_year = $this->data->end_year;
    my $footwear = $this->data->footwear;
    my @colors = color_list __PACKAGE__, @$footwear;

    my @data;
    for my $Y ($begin_year .. $end_year) {
        for my $q (1 .. 4) {
            my ($dist, %foot_data) = (0, ());
            for (@$footwear) {
                my $foot_dist = $this->_dist($Y, $q, $_);
                $foot_data{$_} = $foot_dist if $foot_dist;
                $dist += $foot_dist;
            }
            push @data, {quarter => "Q$q-$Y", %foot_data} if $dist;
        };
    }

    $this->_chart('stacked-serial-chart.html',
        '<!--CHART-TITLE-->'    => 'Quarterly Miles Run, By Footwear '
                                 . "($begin_year - $end_year)",
        '<!--DIV-ID-->'         => "quarterly-miles-by-foot",
        '<!--JSON-->'           => to_json(\@data),
        '<!--KEYS-->'           => to_json($footwear),
        '<!--COLORS-->'         => to_json(\@colors),
        '<!--CATEGORY-TITLE-->' => 'Quarters',
        '<!--CATEGORY-FIELD-->' => 'quarter',
        '<!--VALUE-TITLE-->'    => 'Miles Run',
    );
}


#///////////////////////////////////////////////////////////////
# Internal use /////////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart::Quarterly $this
# @param int $Y    a year, YYYY
# @param int $q    quarter of year, 1-4
# @param string $f    footwear
# @return float    a number of miles
sub _dist {
    my ($this, $Y, $q, $f) = @_;

    # map quarter to its low & high months
    my %map = (
        1 => [qw(01 03)], 2 => [qw(04 06)],
        3 => [qw(07 09)], 4 => [qw(10 12)]
        );

    # filter for date range & footwear w/in given quarter
    my $low  = join '-', $Y, $map{$q}->[0], '01';
    my $high = join '-', $Y, $map{$q}->[1], '31';
    my $filter = sub {$_->[FOOT] eq $f && 
                      $_->[DATE] ge $low && $_->[DATE] le $high};

    $this->data->how_far($filter);
}

1;
