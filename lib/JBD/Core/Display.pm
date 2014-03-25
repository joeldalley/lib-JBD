package JBD::Core::Display;
# ABSTRACT: template rendering abstraction
# VERSION

#/ A JBD::Core::Display object is a closure over a
#/ template file path and hash of standard replacements,
#/ which, when invoked, calls render() with the closing 
#/ sub's given template file and template replacements.
#/
#/    my $disp = JBD::Core::Display->new(
#/                   '/path/to/templates', 
#/                   '<!--TITLE-->' => 'My Title',
#/                   '<!--COPYRIGHT-->' => 'My Name'
#/               );
#/    print $disp->('my-page.html', '<!--H1-->' => 'Hello');
#/ @author Joel Dalley
#/ @version 2013/Nov/16

use JBD::Core::stern;
use JBD::Core::Template 'render';

#/ @param string $type    object type
#/ @param string $tmpl_path    path to template files
#/ @param hash [optional] %std_repl    standard replacements
#/ @return JBD::Core::Display    blessed coderef
sub new {
    my ($type, $tmpl_path, %std_repl) = (shift, shift, @_);

    #/ @param string $tmpl    a template filename
    #/ @param hash [optional] %repl    template replacements
    #/ @return string    rendered template file content
    my $this = sub {
        my ($tmpl, %repl) = (shift, @_);
        my $file = join '/', $tmpl_path, $tmpl;
        render $file, (%std_repl, %repl);
    };

    bless $this, $type;
}

1;
