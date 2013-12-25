
# Display subclass for the charts page.
# @author Joel Dalley
# @version 2013/Oct/13

package JBD::Tempo::Display::Charts;

use parent 'JBD::Tempo::Display';

use JBD::Core::stern;
use JBD::Tempo::Display::Chart 'new_from';

#//////////////////////////////////////////////////////////////
# Object Interface ////////////////////////////////////////////

# @param JBD::Tempo::Display::Charts $this
# @return string    html
sub charts {
    my $this = shift;

    # currently loaded charts html
    my $total = new_from('Total', $this)->chart;
    my $annual = new_from('Annual', $this)->chart;
    my $quarterly = new_from('Quarterly', $this)->chart;

    # ajax html - deferred loading
    my $chart = JBD::Tempo::Display::Chart->from($this);
    my $by_foot = $chart->ajax_html('Quarterly::ByFootwear');
    my $by_surf = $chart->ajax_html('Quarterly::BySurface');
    my $by_day = $chart->ajax_html('Quarterly::ByDay');
    my $avg_dist = $chart->ajax_html('Quarterly::AverageDistance');

    $this->show('charts-container.html',
        '<!--TOTAL-->'        => $total,
        '<!--ANNUAL-->'       => $annual,
        '<!--QUARTERLY-->'    => $quarterly,
        '<!--BY-FOOTWEAR-->'  => $by_foot,
        '<!--BY-SURFACE-->'   => $by_surf,
        '<!--BY-DAY-->'       => $by_day,
        '<!--AVG-DISTANCE-->' => $avg_dist
    );
}

1;
