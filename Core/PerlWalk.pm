
#/ Wrapper for File::DirWalk.
#/ @author Joel Dalley
#/ @version 2013/Oct/27

package JBD::Core::PerlWalk;

use JBD::Core::stern;
use File::DirWalk;

use Exporter 'import';
our @EXPORT_OK = qw(on_file);

#/ @param coderef $callback    called on each perl file
#/ @param array    zero or more file paths
sub on_file(&@) {
    my $callback = shift;

    #/ callback is wrapped so it always skips non-perl
    #/ files, and always returns File::DirWalk::SUCCESS 
    my $wrapper = sub {
        my $file = shift;
        $callback->($file) if $file =~ /\.(pl|pm6?|p6)$/o;
        File::DirWalk::SUCCESS;
    };

    my $walker = File::DirWalk->new;
    $walker->onFile($wrapper);
    $walker->walk($_) for @_;
}

1;
