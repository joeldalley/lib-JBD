
#/ Add form display.
#/ @author Joel Dalley
#/ @version 2013/Nov/16

package JBD::Tempo::Display::AddForm;

use parent 'JBD::Tempo::Display';

#/ @param JBD::Tempo::Display::AddForm $this
#/ @param string $passkey    for quote-unquote security
#/ @param arrayref $foot_list    array of footwear
#/ @param arrayref $surf_list    array of surfaces
#/ @return string    add form page html
sub form {
    my ($this, $passkey, $foot_list, $surf_list) = @_;

    my @foot_opts = map $this->show('select-opt.html',
        '<!--VALUE-->'    => $_,
        '<!--TEXT-->'     => $_,
        '<!--SELECTED-->' => '',
    ), @$foot_list;

    my @surf_opts = map $this->show('select-opt.html',
        '<!--VALUE-->'    => $_,
        '<!--TEXT-->'     => $_,
        '<!--SELECTED-->' => '',
    ), @$surf_list;

    $this->show('add-run-form.html',
        '<!--PASSKEY-->'   => $passkey,
        '<!--FOOT-OPTS-->' => join('', @foot_opts),
        '<!--SURF-OPTS-->' => join('', @surf_opts)
    );
}

1;
