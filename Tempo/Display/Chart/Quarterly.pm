
# Quarterly miles run chart.
# @author Joel Dalley
# @version 2013/Dec/24

package JBD::Tempo::Display::Chart::Quarterly;

use parent 'JBD::Tempo::Display::Chart';

use JBD::Core::stern;
use JBD::Tempo::Color 'next_color';
use JBD::Tempo::Data 'DATE';
use JSON 'to_json';


#///////////////////////////////////////////////////////////////
# Interface ////////////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart::Quarterly $this
# @return hash    template replacements
sub chart {
    my $this = shift;

    my $begin_year = $this->data->begin_year;
    my $end_year   = $this->data->end_year;

    my @data;
    for my $Y ($begin_year .. $end_year) {
        for my $q (1 .. 4) {
            my $miles = $this->_dist($Y, $q) or next;
            push @data, {
                miles   => $miles,
                quarter => "Q$q-$Y",
                color   => next_color(__PACKAGE__)
            }
        };
    }

    $this->_chart('serial-chart.html',
        '<!--CHART-TITLE-->'    => 'Quarterly Miles Run '
                                 . "($begin_year - $end_year)",
        '<!--DIV-ID-->'         => "quarterly-miles",
        '<!--JSON-->'           => to_json(\@data),
        '<!--CATEGORY-TITLE-->' => 'Quarters',
        '<!--CATEGORY-FIELD-->' => 'quarter',
        '<!--VALUE-TITLE-->'    => 'Miles Run',
        '<!--VALUE-FIELD-->'    => 'miles'
    );
}


#///////////////////////////////////////////////////////////////
# Internal use /////////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart::Quarterly $this
# @param int $Y    a year, YYYY
# @param int $q    quarter of year, 1-4
# @return float    a number of miles
sub _dist {
    my ($this, $Y, $q) = @_;

    # map quarter to its low & high months
    my %map = (
        1 => [qw(01 03)], 2 => [qw(04 06)],
        3 => [qw(07 09)], 4 => [qw(10 12)]
        );

    # filter for date range w/in given quarter
    my $low  = join '-', $Y, $map{$q}->[0], '01';
    my $high = join '-', $Y, $map{$q}->[1], '31';
    my $filter = sub {$_->[DATE] ge $low && $_->[DATE] le $high};

    $this->data->how_far($filter);
}

1;
