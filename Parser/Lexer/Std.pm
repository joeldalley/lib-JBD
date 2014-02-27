
# Provides standard lexer types.
# @author Joel Dalley.
# @version 2014/Feb/24

package JBD::Parser::Lexer::Std;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';

no strict 'refs';

# Helper sub for pattern-matchers.
# @param string $text Arbitrary/Unstructured text.
# @param regex $regex Pattern to match.
# @return array Array of (remaining text, matched text).
sub _($$) {
    my ($text, $regex) = @_;
    $text =~ $regex;
    return ($text) unless defined $1 && length $1;
    my $diff = length($text) - length $1;
    $text = substr $text, length($1), $diff;
    ($text, $1);
}

# Map of { package symbol => pattern-matcher sub }.
my %symbol_definitions = (
    Space => sub { _ shift, qr{^(\s+)}o },
    Word  => sub { _ shift, qr{^([a-z\.]+)}io },
    Float => sub { _ shift, qr{^(\d+\.\d*)}o },
    Dot   => sub { _ shift, qr{^(\.+)}o },
    Ratio => sub { _ shift, qr{^(\d+\/\d+)}o },
    Int   => sub { _ shift, qr{^(\d+)}o },
    Op    => sub { _ shift, qr{^([\+\*\-\\/\(\)]{1})}o },
);

# Transform symbol definitions into package symbols.
while (my ($sym, $sub) = each %symbol_definitions) {
    *{__PACKAGE__ . "::$sym"} = sub { bless $sub, $sym };
}

1;
