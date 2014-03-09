
# Provides standard lexer types.
# @author Joel Dalley.
# @version 2014/Feb/24

package JBD::Parser::Lexer::Std;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';
no strict 'refs';

# Map of {Package symbol => pattern-matcher sub}.
my %map = (
    Num      => sub { _Num(shift)                  },
    Unsigned => sub { _num(shift, 'unsigned')      },
    Signed   => sub { _num(shift, 'signed')        },
    Float    => sub { _float(shift)                },
    Int      => sub { shift =~ qr{^([-+]?\d+)}o; $1},
    Op       => sub { _op(shift)                   },
    Space    => sub { shift =~ qr{^(\s+)}o;      $1},
    Word     => sub { shift =~ qr{^(\w+)}io;     $1},
    );
my @std_symbols;

# Transform symbol definitions into package symbols.
while (my ($sym, $sub) = each %map) {
    my $typed = sub { bless $sub, $sym };
    *{__PACKAGE__ . "::$sym"} = sub { bless $sub, $sym };
    push @std_symbols, bless $sub, $sym;
}

# @return array All map symbols.
sub std_symbols() { @std_symbols }

# @param string Input characters.
# @return Matched operator character, or undef.
sub _op($) {
    my $chars = shift;
    my $alphabet = '()+*-/';
    return unless length $chars;
    my $i = index $alphabet, substr $chars, 0, 1;
    $i >= 0 ? substr $alphabet, $i, 1 : undef;
}

# @param string Input characters.
# @return Matched floating point number, or undef.
sub _float($) {
    my $r1 = qr{[-+]?[0-9]*\.[0-9]+([eE][-+]?[0-9]+)?}o;
    my $r2 = qr{[-+]?[0-9]+\.[0-9]*([eE][-+]?[0-9]+)?}o;
    shift =~ qr{^($r1|$r2)}; $1;
}

# @param string $chars Input characters.
# @param string [opt] $spec Specify signed or unsigned.
# @return Matched number, or undef.
sub _num($;$) {
    my ($chars, $spec) = @_;

    # Order matters!
    no strict 'refs';
    for (qw(Float Int)) { 
        my $n = &$_->($chars);
        next unless defined $n;
        return $n if !defined $spec;
        $n =~ /^([\+-])/o;
        return $n if $spec eq 'unsigned' && !defined $1 
                  || $spec eq 'signed'   &&  defined $1;
    }
    undef;
}

# @param string $chars Input characters.
# @return Matched number, or undef.
sub _Num($) {
    my $chars = shift;
    my $s = _num($chars, 'signed');
    defined $s ? $s : _num($chars, 'unsigned');
}

1;
