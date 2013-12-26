
# Provides get(), which returns response content, per
# the requested route, with the help of a display object.
# @author Joel Dalley
# @version 2013/Nov/16

# @param JBD::Tempo::Display $disp    display object
# @param hash %params    k/v pairs of CGI/ENV data
# @return mixed    either the response content, or 0
sub get($%) {
    my ($disp, %params) = (shift, @_);
    my $route = $params{route};

    # home / philosophy page
    grep $route eq $_, ('', 'philosophy') and do {
        my $content = $disp->show('philosophy.html');
        return $disp->page('Running Philosophy', $content);
    };

    # run charts page
    $route eq 'charts' and do {
        require JBD::Tempo::Display::Charts;
        my $charts = JBD::Tempo::Display::Charts->from($disp);
        return $charts->page('Run Charts', $charts->charts);
    };

    # single chart
    $route eq 'ajax/chart' and $params{chart} and do {
        require JBD::Tempo::Display::Chart;
        my $sub = \&JBD::Tempo::Display::Chart::new_from;
        return $sub->($params{chart}, $disp)->chart;
    };

    # recent runs page
    $route eq 'recent' and do {
        require JBD::Tempo::Display::Summary;
        my $sum = JBD::Tempo::Display::Summary->from($disp);
        return $disp->page('Recent Runs', $sum->summary);
    };

    # run log page
    $route eq 'runlog' and do {
        require JBD::Tempo::Display::Log;
        my $log = JBD::Tempo::Display::Log->from($disp);
        return $disp->page('Run Log', $log->log);
    };

    0;
}

1;
