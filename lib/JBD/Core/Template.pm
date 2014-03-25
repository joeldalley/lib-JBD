package JBD::Core::Template;
# ABSTRACT: provides render, which merges a template file and replacements
# VERSION

#/ Provides render(), which takes a template file and its
#/ (placeholder, value) pairs, and renders the template.
#/ @author Joel Dalley
#/ @version 2013/Oct/27

use JBD::Core::stern;
use Carp 'croak';
use File::Slurp;

use Exporter 'import';
our @EXPORT_OK = qw(render);

my %cache;


#///////////////////////////////////////////////////////////////
#/ Interface ///////////////////////////////////////////////////

#/ @param string $file    a template file path
#/ @param hash [optional] %repl    placeholder/value pairs
sub render($;%) {
    my ($file, %repl) = (shift, @_);

    #/ load
    exists $cache{$file} or do {
        $cache{$file} = read_file $file 
            or croak "No such template file `$file`";
    };

    #/ replace
    my $text = $cache{$file};
    while (my ($k, $v) = each %repl) { $text =~ s/$k/$v/g }

    $text;
}

1;
