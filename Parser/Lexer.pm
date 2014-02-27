
# Subs for lexing the given input against the given patterns.
# input() wraps tokens(), and applies a useful default input
# token array filter--it removes white spaces--and returns
# a JBD::Parser::Input, suitable for passing to a Parser sub.
# @author Joel Dalley
# @version 2014/Feb/23

package JBD::Parser::Lexer;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';

use JBD::Parser::Lexer::Std 'Space';
use JBD::Parser::Token;
use JBD::Parser::Input;
use Carp 'croak';

# @param scalar $text Unstructured/arbitrary text.
# @param arrayref $matchers Pattern-matcher subs.
# @param coderef [opt] $sift Input token filter, or undef.
# @return arrayref An array of JBD::Parser::Tokens.
sub tokens($$;$) {
    my $text = shift;
    my ($matchers, $sift) = @_;

    ref $text and croak 'Input must be scalar (text)';

    my @tok;
    while (length $text) {
        my $v;
        MATCH: for my $m (@$matchers) {
            ($text, $v) = $m->($text);
            next unless defined $v;
            push @tok, JBD::Parser::Token->new(ref $m, $v);
            last MATCH;
        }
        $text = substr $text, 1, length($text)-1 if !$v;
    }

    push @tok, JBD::Parser::Token->end_of_input;
    ref $sift ? [grep $sift->($_), @tok] : \@tok;
}

# @param scalarref $text Unstructured/arbitrary text.
# @param arrayref $matchers Pattern-matcher subs.
# @param coderef [opt] $sift Input token filter, or undef.
# @return JBD::Parser::Input
sub input($$;$) {
    my ($text, $matchers) = (shift, shift);
    my $sift = shift || sub {!$_->typeis(Space)};
    my $tokens = tokens $text, $matchers, $sift;
    JBD::Parser::Input->new($tokens);
}

1;
