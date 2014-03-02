
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
use JBD::Parser::Token 'token';
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
    while ($text) {
        my ($type, $value) = ('', '');

        for my $m (@$matchers) {
            my $v = $m->($text) || '';
            if (length $v > length $value) {
                $type = ref $m;
                $value = $v;
            }
        }

        my $lv = $value && length $value || 0;
        my $lt = $text  && length $text  || 0;

        if ($lv && $lt > $lv) {
            $text = substr $text, $lv;
        }
        elsif ($lv && $lt == $lv) {
            $text = undef;
        }
        elsif (!$lv) {
            $text = $lt > 1 ? substr $text, 1 : undef;
        }

        push @tok, token $type, $value if $value;
    }

    ref $sift ? [grep $sift->($_), @tok] : \@tok;
}

# @param scalarref $text Unstructured/arbitrary text.
# @param arrayref $matchers Pattern-matcher subs.
# @param hashref [opt] $opts Optional k/v pairs.
# @return JBD::Parser::Input
sub input($$;$) {
    my ($text, $matchers, $opts) = @_;
    my $sift = $opts->{sift} || sub {!$_->typeis(Space)};
    my $tokens = tokens $text, $matchers, $sift;
    push @$tokens, @{$opts->{tail}} if $opts->{tail};
    JBD::Parser::Input->new($tokens);
}

1;
