
# Weekly miles run chart.
# @author Joel Dalley
# @version 2013/Nov/16

package JBD::Tempo::Display::Chart::Weekly;

use parent 'JBD::Tempo::Display::Chart';

use JBD::Core::stern;
use JBD::Core::Date;
use JBD::Tempo::Color 'next_color';
use JBD::Tempo::Data 'DATE';
use JSON 'to_json';

use constant SECS => 604800; # 7 days, in sec


#//////////////////////////////////////////////////////////////
# Interface ///////////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart::Weekly $this
# @param int $weeks    number of weeks to show
# @return string    container + chart html
sub chart {
    my ($this, $weeks) = @_;

    my @data;
    my $now = time;

    for my $num (reverse (1 .. $weeks)) {
        my $begin = JBD::Core::Date->new($now - $num * SECS);
        my $end = JBD::Core::Date->new($now - ($num-1) * SECS);

        push @data, {
            miles => $this->_dist($begin, $end),
            week => $end->formatted('%D'),
            color => next_color(__PACKAGE__ . $weeks)
            };
    }

    $this->_chart('serial-chart.html',
        '<!--CHART-TITLE-->'    => "Weekly Miles Run",
        '<!--DIV-ID-->'         => "week-miles-chart-$now",
        '<!--JSON-->'           => to_json(\@data),
        '<!--CATEGORY-TITLE-->' => 'Week Ending',
        '<!--CATEGORY-FIELD-->' => 'week',
        '<!--VALUE-TITLE-->'    => 'Miles Run',
        '<!--VALUE-FIELD-->'    => 'miles'
    );
}


#//////////////////////////////////////////////////////////////
# Internal use  ///////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart::Weekly $this
# @param JBD::Core::Date $begin
# @param JBD::Core::Date $end
# @return float    number of miles
sub _dist {
    my ($this, $begin, $end) = @_;
    $this->data->how_far(sub {
        $_->[DATE] gt $begin->formatted('%F') && 
        $_->[DATE] le $end->formatted('%F')
    });
}

1;
