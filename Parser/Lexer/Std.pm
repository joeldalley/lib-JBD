
# Provides standard lexer types.
# @author Joel Dalley.
# @version 2014/Feb/24

package JBD::Parser::Lexer::Std;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';
no strict 'refs';

# Map of {Package symbol => pattern-matcher sub}.
my %map = (
    Space => sub { shift =~ qr{^(\s+)}o;                $1},
    Word  => sub { shift =~ qr{^([a-z\.]+)}io;          $1},
    Float => sub { my $f =  _float(shift);              $f},
    Ratio => sub { shift =~ qr{^([-+]?\d+/[-+]?\d+)}o;  $1},
    Int   => sub { shift =~ qr{^([-+]?\d+)}o;           $1},
    Dot   => sub { shift =~ qr{^(\.+)}o;                $1},
    Op    => sub { my $o =  _op(substr +shift, 0, 1);   $o},
    );

# @return array All map symbols.
sub std_symbols() { sort keys %map }

# Transform symbol definitions into package symbols.
while (my ($sym, $sub) = each %map) {
    *{__PACKAGE__ . "::$sym"} = sub { bless $sub, $sym };
}

# @param string An input Character.
# @return Matched operator character, or undef.
sub _op($) {
    my $alphabet = '()+*-/';
    my $i = index $alphabet, $_[0];
    $i >= 0 ? substr $alphabet, $i, 1 : undef;
}

# @param string Input characters.
# @return Matched floating point number, or undef.
sub _float($) {
    my $r1 = qr{[-+]?[0-9]*\.[0-9]+([eE][-+]?[0-9]+)?}o;
    my $r2 = qr{[-+]?[0-9]+\.[0-9]*([eE][-+]?[0-9]+)?}o;
    shift =~ qr{^($r1|$r2)}; $1;
}

1;
