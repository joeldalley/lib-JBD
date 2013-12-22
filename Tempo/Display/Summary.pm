
#/ summary() returns the html of the recent run summary page.
#/ @author Joel Dalley
#/ @version 2013/Oct/13

package JBD::Tempo::Display::Summary;

use parent 'JBD::Tempo::Display';

use JBD::Core::stern;
use JBD::Tempo::Display::Chart::Monthly;
use JBD::Tempo::Display::Chart::Recent;
use JBD::Tempo::Display::Chart::Weekly;
use JBD::Tempo::Display::Log;


#///////////////////////////////////////////////////////////////
#/ Object Interface ////////////////////////////////////////////

#/ @param JBD::Tempo::Display::Summary $this
#/ @return string    html
sub summary {
    my $this = shift;

    my $log = JBD::Tempo::Display::Log->from($this);
    my $recent = JBD::Tempo::Display::Chart::Recent->from($this);
    my $weekly = JBD::Tempo::Display::Chart::Weekly->from($this);
    my $monthly = JBD::Tempo::Display::Chart::Monthly->from($this);

    $this->show('summary-container.html',
        '<!--RECENT-CHART-->'  => $recent->chart,
        '<!--WEEKLY-CHART-->'  => $weekly->chart(7),
        '<!--MONTHLY-CHART-->' => $monthly->chart($this->date->Y),
        '<!--RECENT-LOG-->'    => $log->log(10)
    );
}

1;
