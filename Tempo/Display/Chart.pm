
#/ Provides pie() and serial() for returning charts.
#/ @author Joel Dalley
#/ @version 2013/Oct/12

package JBD::Tempo::Display::Chart;

use parent 'JBD::Tempo::Display';
use JBD::Core::stern;


#///////////////////////////////////////////////////////////////
#/ Interface ///////////////////////////////////////////////////

#/ @param JBD::Tempo::Display::Chart $this;
sub chart { 
    my $ref = ref shift;
    die "$ref: must override!"; 
}


#///////////////////////////////////////////////////////////////
#/ Internal use ////////////////////////////////////////////////

#/ @param JBD::Tempo::Display::Chart $this
#/ @param string $tmpl    chart template
#/ @param hash %repl    template replacements
#/ @return string    container + chart html
sub _chart {
    my ($this, $tmpl, %repl) = (shift, shift, @_);

    $this->show('chart-container.html', 
        '<!--CHART-->', $this->show($tmpl, %repl),
        %repl
    );
}

1;
