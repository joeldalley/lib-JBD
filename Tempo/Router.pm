
#/ Provides get(), which returns response content, per
#/ the requested route, with the help of a display object.
#/ @author Joel Dalley
#/ @version 2013/Nov/16

#/ @param string $route    route name
#/ @param JBD::Tempo::Display $disp    display object
#/ @return mixed    either the response content, or 0
sub get($$) {
    my ($route, $disp) = @_;

    grep $route eq $_, ('', 'philosophy') and do {
        my $content = $disp->show('philosophy.html');
        return $disp->page('Running Philosophy', $content);
    };

    $route eq 'recent' and do {
        require JBD::Tempo::Display::Summary;
        my $sum = JBD::Tempo::Display::Summary->from($disp);
        return $disp->page('Recent Runs', $sum->summary);
    };

    $route eq 'runlog' and do {
        require JBD::Tempo::Display::Log;
        my $log = JBD::Tempo::Display::Log->from($disp);
        return $disp->page('Run Log', $log->log);
    };

    0;
}

1;
