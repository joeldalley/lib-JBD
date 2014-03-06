
# match()  - Determines the token (type, value) pair for
#            the given text and associated pattern-matcher
#            subs. Matcher subs array order is important.
#            The first sub that yields a pair is returned.
#
# tokens() - Iterates over match() with its input text, 
#            and chooses whichever token (type, value) pair 
#            match has the longest value (character count).
#            In this manner, input text of '-1.0' with 
#            matcher subs Int and Float defined in
#            JBD::Parser::Lexer::Std would lex like this:
#
#            Int->('-1.0')   --> '-1'   match len: 2.
#            Float->('-1.0') --> '-1.0' match len: 4.
#                ====> Float is chosen.
#
# input() - Shorthand for tokens() + JBD::Parser::Input->new.

# @author Joel Dalley
# @version 2014/Feb/23

package JBD::Parser::Lexer;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';

use JBD::Parser::Token 'token';
use Scalar::Util 'reftype';
use JBD::Parser::Input;
use Carp 'croak';

# @param scalar $text Unstructured/arbitrary text.
# @param arrayref $matchers Pattern-matcher subs.
# @param coderef [opt] $want Token value requirement sub.
# @return mixed Array of (type, value), or undef.
sub match($$;$) {
    my ($text, $matchers) = (shift, shift);
    my $want = shift || sub {defined $_[0]};
    for my $m (@$matchers) {
        my ($mtype, $mref) = (ref $m, reftype $m);

        croak 'Element valued `' . substr($m, 0, 24) . '`'
            . " is not a CODE ref; given text `$text`"
            unless $mtype;
        croak "Element reference typed `$mtype` in matchers"
            . " array isn't CODE; given text `$text`" 
            unless $mref eq 'CODE';

        my $v = $m->($text);
        return [ref $m, $v] if $want->($v);
    }
    undef;
}

# @param scalar $text Unstructured/arbitrary text.
# @param arrayref $matchers Pattern-matcher subs.
# @param coderef [opt] $sift Input token filter, or undef.
# @return scalar: An arrayref of JBD::Parser::Tokens.
#         array: ([JBD::Parser::Tokens], length of tokenized text).
sub tokens($$;$) {
    my $text = shift;
    my ($matchers, $sift) = @_;

    ref $text and croak 'Input must be scalar (text)';

    my (@tok, $matched);
    while (length $text) {
        my @best = ('', '');
        my $pair = match $text, $matchers, sub { 
            my $v = shift;
            return unless defined $v;
            length $v > length $best[0] 
        };
        my $lv = ref $pair && length $pair->[1] || 0;
        ref $pair && do {@best = @$pair; $matched += $lv};
        my $lt = defined $text && length $text  || 0;

        if ($lv && $lt > $lv) {
            $text = substr $text, $lv;
        }
        elsif ($lv && $lt == $lv) {
            $text = undef;
        }
        elsif (!$lv) {
            $text = $lt > 1 ? substr $text, 1 : undef;
        }

        next unless defined $pair->[1] && length $pair->[1];
        push @tok, token shift @best, shift @best;
    }

    @tok = ref $sift ? grep $sift->($_), @tok : @tok;
    wantarray ? (\@tok, $matched) : \@tok;
}

# @param scalarref $text Unstructured/arbitrary text.
# @param arrayref $matchers Pattern-matcher subs.
# @param hashref [opt] $opts Optional k/v pairs.
# @return JBD::Parser::Input
sub input($$;$) {
    my ($text, $matchers, $opts) = @_;
    my $tokens = tokens $text, $matchers, $opts->{sift};
    push @$tokens, @{$opts->{tail}} if $opts->{tail};
    JBD::Parser::Input->new($tokens);
}

1;
