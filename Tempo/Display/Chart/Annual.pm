
# Annual miles run chart.
# @author Joel Dalley
# @version 2013/Dec/24

package JBD::Tempo::Display::Chart::Annual;

use parent 'JBD::Tempo::Display::Chart';

use JBD::Core::stern;
use JBD::Tempo::Color 'color_list';
use JBD::Tempo::Data 'DATE';
use JSON 'to_json';

#//////////////////////////////////////////////////////////////
# Interface ///////////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart::Annual $this
# @return string    container + chart html
sub chart {
    my $this = shift;

    my $begin_year = $this->data->begin_year;
    my $end_year   = $this->data->end_year;

    my @pairs;
    for my $Y ($begin_year .. $end_year) {
        my $filter = sub {index($_->[DATE], "$Y-") == 0}; 
        my $dist = $this->data->how_far($filter);
        push @pairs, {title => $Y, value => $dist};
    }

    my @colors = color_list(__PACKAGE__, scalar @pairs);
    my $json = to_json(\@pairs);

    $this->_chart('pie-chart.html',
        '<!--CHART-TITLE-->' => 'Annual Miles Run',
        '<!--DIV-ID-->'      => 'annual-chart',
        '<!--COLORS-->'      => join (',', map qq/"$_"/, @colors),
        '<!--JSON-->'        => $json,
    );
}

1;
