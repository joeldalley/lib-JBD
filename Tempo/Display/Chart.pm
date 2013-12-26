
# Displays subclass for charts.
# @author Joel Dalley
# @version 2013/Oct/12

package JBD::Tempo::Display::Chart;

use parent 'JBD::Tempo::Display';

use JBD::Core::stern;
use Module::Load;

use Exporter 'import';
our @EXPORT_OK = qw(new_from);


#//////////////////////////////////////////////////////////////
# Object constructor //////////////////////////////////////////

# @param string $subclass    subclass name, e.g., 'Annual'
# @param JBD::Tempo::Display $from    clone data from
# @return JBD::Tempo::Display::Chart    display chart object
sub new_from($$) {
    my ($subclass, $from) = @_;
    my $pkg = "JBD::Tempo::Display::Chart::$subclass";
    load $pkg; $pkg->from($from);
}


#//////////////////////////////////////////////////////////////
# Object interface ////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart $this
# @param string $subclass    subclass name, e.g., 'Annual'
sub ajax_html {
    my ($this, $subclass) = @_;
    (my $div_id = $subclass) =~ s{::}{_}g;
    $this->show('ajax-chart.html', 
        '<!--DIV-ID-->' => $div_id,
        '<!--CHART-->'  => $subclass
    );
}

# @param JBD::Tempo::Display::Chart $this
sub chart { 
    my $ref = ref shift;
    die "$ref: must override!"; 
}


#//////////////////////////////////////////////////////////////
# Internal use ////////////////////////////////////////////////

# @param JBD::Tempo::Display::Chart $this
# @param string $tmpl    chart template
# @param hash %repl    template replacements
# @return string    container + chart html
sub _chart {
    my ($this, $tmpl, %repl) = (shift, shift, @_);

    $this->show('chart-container.html', 
        '<!--CHART-->', $this->show($tmpl, %repl),
        %repl
    );
}

1;
