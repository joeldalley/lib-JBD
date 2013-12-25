
# Quarterly miles run chart, broken down by day.
# @author Joel Dalley
# @version 2013/Dec/24

package JBD::Tempo::Display::Chart::Quarterly::ByDay;

use parent 'JBD::Tempo::Display::Chart';

use JBD::Core::stern;
use JBD::Core::Date;
use JBD::Tempo::Color 'color_list';
use JBD::Tempo::Data 'DATE';
use JSON 'to_json';


#///////////////////////////////////////////////////////////////
# Interface ////////////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart::Quarterly::ByDay $this
# @return hash    template replacements
sub chart {
    my $this = shift;

    my $begin_year = $this->data->begin_year;
    my $end_year = $this->data->end_year;
    my @days = qw(Mon Tue Wed Thu Fri Sat Sun);
    my @colors = color_list __PACKAGE__, @days;

    my @data;
    for my $Y ($begin_year .. $end_year) {
        for my $q (1 .. 4) {
            my ($dist, %day_data) = (0, ());
            for (@days) {
                my $day_dist = $this->_dist($Y, $q, $_);
                $day_data{$_} = $day_dist if $day_dist;
                $dist += $day_dist;
            }
            push @data, {quarter => "Q$q-$Y", %day_data} if $dist;
        };
    }

    $this->_chart('stacked-serial-chart.html',
        '<!--CHART-TITLE-->'    => 'Quarterly Miles Run, By Day '
                                 . "($begin_year - $end_year)",
        '<!--DIV-ID-->'         => "quarterly-miles-by-day",
        '<!--JSON-->'           => to_json(\@data),
        '<!--KEYS-->'           => to_json(\@days),
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
# @param string $d    day
# @return float    a number of miles
sub _dist {
    my ($this, $Y, $q, $d) = @_;

    # map quarter to its low & high months
    my %map = (
        1 => [qw(01 03)], 2 => [qw(04 06)],
        3 => [qw(07 09)], 4 => [qw(10 12)]
        );

    # filter for date range & day w/in given quarter
    my $low  = join '-', $Y, $map{$q}->[0], '01';
    my $high = join '-', $Y, $map{$q}->[1], '31';

    my $filter = sub {
        return 0 unless $_->[DATE] ge $low && $_->[DATE] le $high;
        JBD::Core::Date->new_from_Ymd($_->[DATE])->weekday_abbr eq $d
    };

    $this->data->how_far($filter);
}

1;
