
#/ File utilties. Note that this is mostly an alternative to
#/ File::Slurp, which may not be installed on web hosts where
#/ code using JBD::Core runs.
#/ @author Joel Dalley
#/ @version 2013/Oct/26

package JBD::Core::File;

use JBD::Core::stern;
use Exporter 'import';
our @EXPORT_OK = qw(read write);


#///////////////////////////////////////////////////////////////
#/ Interface ///////////////////////////////////////////////////

#/ @param string $file    file path
#/ @param int [optional] $size    buffer size; default 1024
#/ @return string    file content
sub read($;$) {
    my ($file, $size) = (shift, shift || 1024);

    my ($data, $buff);
    open F, '<', $file or die "$file -- $!";
    while (read F, $buff, $size) { $data .= $buff }
    close F;
    $data;
}

#/ @param string $file    file path
#/ @param mixed $data    file data
sub write($$) {
    my ($file, $data) = @_;
    open F, '>', $file or die "$file -- $!";
    print F $data;
    close F;
}

1;
