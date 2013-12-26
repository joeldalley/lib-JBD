
# Display subclass for the run log page.
# @author Joel Dalley
# @version 2013/Oct/06

package JBD::Tempo::Display::Log;

use parent 'JBD::Tempo::Display';

use JBD::Core::stern;
use JBD::Core::Date;
use JBD::Tempo::Data qw(DATE DIST FOOT SURF);


#//////////////////////////////////////////////////////////////
# Object interface ////////////////////////////////////////////

# @param JBD::Tempo::Display::Log $this
# @param int [optional] $size    how many rows: default all
# @return string    html
sub log {
    my ($this, $size) = @_;

    my @data = $this->data->copy;
    @data = @data[0 .. $size] if $size;

    return $this->show('run-log-open.html')
         . join('', map $this->_row($_), @data)
         . $this->show('run-log-close.html');
}


#//////////////////////////////////////////////////////////////
# Internal use ////////////////////////////////////////////////

# @param object $this    a Tempo::Display::Log
# @param arrayref $row    a run log data row
# @return string    html
sub _row {
    my ($this, $row) = @_;
    my $date = JBD::Core::Date->new_from_Ymd($row->[DATE]);
    $this->show('run-log-row.html', 
        '<!--DATE-->' => $date->formatted('%a, %b %o, %Y'),
        '<!--DIST-->' => $row->[DIST],
        '<!--SURF-->' => $row->[SURF],
        '<!--FOOT-->' => $row->[FOOT]
    );
}

1;
