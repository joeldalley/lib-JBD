
# Provides standard lexer types.
# @author Joel Dalley.
# @version 2014/Feb/24

package JBD::Parser::Lexer::Std;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';

no strict 'refs';

# Map of { package symbol => pattern-matcher sub }.
my %symbol_definitions = (
    Dot   => sub {shift =~ m{(\.)}o,             $1},
    Space => sub {shift =~ m{(\s+)}o;            $1},
    Int   => sub {shift =~ m{([\d]+)}o;          $1},
    Ratio => sub {shift =~ m{(\d+\/\d+)}o;       $1},
    Float => sub {shift =~ m{([\d\.\-]+)}o;      $1},
    Word  => sub {shift =~ m{([a-z\.]+)}io;      $1},
    Op    => sub {shift =~ m#([\+\*\-\\/(\)])#o; $1},
);

# Transform symbol definitions into package symbols.
while (my ($sym, $sub) = each %symbol_definitions) {
    *{__PACKAGE__ . "::$sym"} = sub { bless $sub, $sym };
}

1;
