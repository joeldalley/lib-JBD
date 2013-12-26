
# Tempo Display class.
# @author Joel Dalley
# @version 2013/Nov/15

package JBD::Tempo::Display;

use JBD::Core::stern;
use JBD::Core::Display;
use JBD::Core::Date;
use JBD::Tempo::Data;
use HTML::Entities;

#//////////////////////////////////////////////////////////////
# Interface ///////////////////////////////////////////////////

# @param string $type    object type
# @param string $tmpl_dir    path to template files
# @param string $data_file    path to run data file
# @return JBD::Tempo::Display
sub new {
    my ($type, $tmpl_dir, $data_file) = @_;

    bless [
        JBD::Core::Display->new($tmpl_dir),
        JBD::Tempo::Data->new($data_file),
        JBD::Core::Date->new
        ], $type;
}

# @param string $type    object type
# @param JBD::Tempo::Display $source    source object
# @return JBD::Tempo::Display
sub from {
    my ($type, $source) = @_;
    bless [@$source], $type;
}

# @param JBD::Tempo::Display
# @param string    a template file
# @param hash [optional]   template replacements
# @return string    html
sub show { 
    my $this = shift;
    $this->[0]->(@_);
}

# @param JBD::Tempo::Display
# @return JBD::Tempo::Data
sub data { shift->[1] }

# @param JBD::Tempo::Display
# @return JBD::Core::Date
sub date { shift->[2] }

# @param JBD::Tempo::Display $this
# @param string $h1    page H1 header
# @param string $content   page content
# @return string    page html
sub page {
    my ($this, $h1, $content) = @_;
    return $this->open($h1)
         . $this->h1($h1)
         . $this->content($content)
         . $this->close;
}

# @param JBD::Tempo::Display $this
# @param string [optional] $subtitle    page subtitle, or undef
# @return string    page open html
sub open {
    my ($this, $subtitle) = @_;

    my $title = "Joel Dalley's Running Site";
    $title = join ' :: ', $title, $subtitle if $subtitle;

    $this->show('page-open.html',
        '<!--TITLE-->'      => $title,
        '<!--BANNER-ALT-->' => $title
    );
}

# @param JBD::Tempo::Display $this
# @param string $h1    H1 header
# @return string    H1 header html
sub h1 { 
    my ($this, $h1) = @_;
    $this->show('h1.html', '<!--H1-->' => encode_entities($h1));
}

# @param JBD::Tempo::Display $this
# @param string $content    page content
# @return string    page content html
sub content {
    my ($this, $content) = @_;
    $this->show('content.html', '<!--CONTENT-->' => $content);
}

# @param JBD::Tempo::Display $this
# @return string    page close html
sub close {
    my $this = shift;
    $this->show('page-close.html',
        '<!--COPY-YEAR-->' => $this->date->Y
    );
}

1;
