
# Recent miles run chart.
# @author Joel Dalley
# @version 2013/Nov/16

package JBD::Tempo::Display::Chart::Recent;

use parent 'JBD::Tempo::Display::Chart';

use JSON 'to_json';
use JBD::Core::stern;
use JBD::Core::Date;
use JBD::Tempo::Color 'color_list';
use JBD::Tempo::Data 'DATE';

#//////////////////////////////////////////////////////////////
# Interface ///////////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart::Recent $this
# @return string    container + chart html
sub chart {
    my $this = shift;

    my $last_7 = JBD::Core::Date->new(time - 86400*6);
    my $last_30 = JBD::Core::Date->new(time - 86400*29);

    my %map = (
        'Last 7 Days'  => $last_7->formatted('%F'),
        'Last 30 Days' => $last_30->formatted('%F')
        );

    my @pairs;
    while (my ($t, $v) = each %map) {
        my $dist = $this->data->how_far(sub {$_->[DATE] ge $v});
        push @pairs, {title => $t, value => $dist};
    }

    my @colors = color_list(__PACKAGE__, scalar @pairs);
    my $json = to_json([sort {$b->{value} <=> $a->{value}} @pairs]);

    $this->_chart('pie-chart.html',
        '<!--CHART-TITLE-->' => 'Recent Miles Run',
        '<!--DIV-ID-->'      => 'recent-chart',
        '<!--COLORS-->'      => join (',', map qq/"$_"/, @colors),
        '<!--JSON-->'        => $json,
    );
}

1;
