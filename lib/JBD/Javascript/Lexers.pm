package JBD::Javascript::Lexers;
# ABSTRACT: Javascript lexers
# VERSION

# Javascript Lexers.
# @author Joel Dalley
# @version 2014/Apr/13

use JBD::Core::Exporter;
use JBD::Parser::DSL;

our @EXPORT = qw(
    SourceCharacter WhiteSpace LineTerminator LineTerminatorSequence
    MultiLineNotForwardSlashOrAsteriskChar PostAsteriskCommentChars
    MultiLineNotAsteriskChar MultiLineCommentChars MultiLineComment
    SingleLineCommentChar SingleLineCommentChars SingleLineComment
    Comment Infinity HexDigit HexIntegerLiteral DecimalDigit NonZeroDigit
    DecimalDigits DecimalIntegerLiteral DecimalLiteral NumericLiteral
    BooleanLiteral NullLiteral StringLiteral RegularExpressionFirstChar
    RegularExpressionChar RegularExpressionTags RegularExpressionBody
    RegularExpressionLiteral Literal SignedInteger ExponentIndicator
    ExponentPart Punctuator UnicodeDigit UnicodeLetter UnicodeCombiningMark
    UnicodeConnectorPunctuation IdentifierStart IdentifierPart IdentifierName
    Identifier Keyword FutureReservedWord ReservedWord Token DivPunctuator
    InputElementDiv InputElementRegExp
    );

sub SourceCharacter {
    bless sub {
        my $chars = shift;
        return unless defined $chars && length $chars;
        substr $chars, 0, 1;
    }, 'SourceCharacter';
}

sub WhiteSpace { bless sub { Space->(shift) }, 'WhiteSpace' }

sub LineTerminator { 
    bless sub { shift =~ m{^(\v+)}o; $1 }, 'LineTerminator' 
}

sub LineTerminatorSequence { 
    bless sub { 
        LineTerminator->(shift) 
    }, 'LineTerminatorSequence'
}

sub MultiLineNotForwardSlashOrAsteriskChar {
    bless sub {
        my $chars = shift;
        return if $chars =~ m{^(/|\*)}o;
        SourceCharacter->($chars);
    }, 'MultiLineNotForwardSlashOrAsteriskChar';
}

sub PostAsteriskCommentChars {
    bless sub {
        my $chars = shift;

        my $not = MultiLineNotForwardSlashOrAsteriskChar->($chars);
        if ($not) {
            return $not unless length($chars) - length($not) > 0;
            my $remain = substr $chars, length $not;
            my $multi = &MultiLineCommentChars->($remain);
            return $not . ($multi ? $multi : '');
        }
        elsif ($chars && $chars =~ m{^\*}o) {
            my $return = '*';
            $chars = substr $chars, 0, 1;
            while (my $next = &PostAsteriskCommentChars->($chars)) {
                $return .= $next;
                last unless length($chars) - length($next) > 0;
                $chars = substr $chars, length $next;
            }
            return $return;
        }

        undef;
    }, 'PostAsteriskCommentChars';
}

sub MultiLineNotAsteriskChar {
    bless sub {
        my $chars = shift;
        return if $chars && $chars =~ m{^\*}o;
        SourceCharacter->($chars);
    }, 'MultiLineNotAsteriskChar';
}

sub MultiLineCommentChars {
    bless sub {
        my $chars = shift;

        my $not = MultiLineNotAsteriskChar->($chars);
        if ($not) {
            my $multi;
            return $not unless length($chars) - length($not) > 0;
            $chars = substr $chars, length $not;
            while (my $next = &MultiLineCommentChars->($chars)) {
                $multi .= $next;
                last unless length($chars) - length($next) >= 0;
                $chars = substr $chars, length $next;
            }
            return $not . ($multi ? $multi : '');
        }
        elsif ($chars && $chars =~ m{^\*}o) {
            my $post = &PostAsteriskCommentChars->(substr $chars, 1);
            return '*' . ($post ? $post : '');
        }

        undef;
    }, 'MultiLineCommentChars';
}

sub MultiLineComment {
    bless sub {
        my $chars = shift;
        return unless $chars && $chars =~ m{^(/\*)}o;

        $chars  = substr $chars, 2;
        my $pos = index($chars, '*/');
        return unless $pos > 0;
        $chars = substr $chars, 0, $pos-1;

        my $multi = MultiLineCommentChars->($chars);
        '/*' . ($multi ? $multi : '') . '*/';
    }, 'MultiLineComment';
}

sub SingleLineCommentChar {
    bless sub {
        my $chars = shift;
        return if LineTerminator->($chars);
        SourceCharacter->($chars);
    }, 'SingleLineCommentChar';
}

sub SingleLineCommentChars {
    bless sub {
        my $chars = shift;
          
        my $first = SingleLineCommentChar->($chars);
        return unless $first;

        my $return = $first;
        $chars = substr $chars, length $first;

        while (my $next = SingleLineCommentChar->($chars)) {
            $return .= $next;
            last unless length($chars) - length($next) >= 0;
            $chars = substr $chars, length $next;
        }
        $return;
    }, 'SingleLineCommentChars';
}

sub SingleLineComment {
    bless sub {
        my $chars = shift;
        return unless $chars
            && length $chars > 1
            && $chars =~ m{^//}o;
        my $single = SingleLineCommentChars->(substr $chars, 2);
        '//' . ($single ? $single : '');
    }, 'SingleLineComment';
}

sub Comment {
    bless sub {
        my $chars = shift;
        MultiLineComment->($chars) 
        || SingleLineComment->($chars);
    }, 'Comment';
}

sub Infinity {
    bless sub { 
        shift =~ /^(\+|-)Infinity/o or return;
        $1 . 'Infinity';
    }, 'Infinity';
}

sub HexDigit {
    bless sub { shift =~ /^([0-9a-f])/io; $1 }, 'HexDigit';
}

sub HexIntegerLiteral {
    bless sub { 
        my $chars = shift;
        if ($chars =~ /^0x/o) {
            my $digit = HexDigit->(substr $chars, 2) or return;
            return '0x' . $digit;
        }
        my $literal = &HexIntegerLiteral->($chars) or return;
        $chars = substr $chars, length $literal;
        my $digit = HexDigit->($chars) or return;
        $literal . $digit;
    }, 'HexIntegerLiteral';
}

sub DecimalDigit {
    my $or = join '|', qw(0 1 2 3 4 5 6 7 8);
    my $r = qr/^($or)/o;
    bless sub { shift =~ $r; $1 }, 'DecimalDigit';
}

sub NonZeroDigit {
    bless sub {
        my $chars = shift;
        return if $chars =~ /^0/o;
        DecimalDigit->($chars);
    }, 'NonZeroDigit';
}

sub DecimalDigits {
    bless sub {
        my $chars = shift;
        my $digits = DecimalDigit->($chars) or return;
        while (my $next = DecimalDigit->($chars)) {
            $digits .= $next;
        }
        $digits;
    }, 'DecimalDigits';
}

sub DecimalIntegerLiteral {
    bless sub {
        my $chars = shift;

        return unless $chars =~ /^0/o;
        $chars = substr $chars, 1;

        my $digit = NonZeroDigit->($chars);
        return '0' unless $digit;

        $chars = substr $chars, length $digit;
        my $digits = DecimialDigits->($chars);

        '0' . $digit . ($digits ? $digits : '');
    }, 'DecimalIntegerLiteral';
}

sub DecimalLiteral {
    bless sub {
        my $chars = shift;

        my $first = $chars =~ /^\./o && '.'
                 || DecimalIntegerLiteral->($chars);

        if ($first eq '.') {
            $chars = substr $chars, 1;
            my $digits = DecimalDigits->($chars) or return;
            $chars = substr $chars, (1 + length $digits);
            my $exp = ExponentPart->($chars);
            $first . $digits . ($exp ? $exp : '');
        }
        else {
            $chars = substr $chars, length $first;

            if ($chars =~ /^\./o) {
                my $digits = DecimalDigits->($chars);
                my $exp; 
                if ($digits) {
                    $chars = substr $chars, (1 + length $digits);
                    $exp = ExponentPart->($chars);
                }

                return $first . ($digits ? $digits : '') 
                              . ($exp ? $exp : '');
            }
            else {
                my $exp = ExponentPart->($chars);
                return $first . ($exp ? $exp : '');
            }
        }
    }, 'DecimalLiteral';
}

sub NumericLiteral {
    bless sub {
        my $chars = shift;
        DecimalLiteral->($chars)
        || HexIntegreLiteral->($chars);
    }, 'NumericLiteral';
}

sub BooleanLiteral {
    sub { shift =~ /^(true|false)/o }, 'BooleanLiteral';
} 
sub NullLiteral { 
    bless sub { shift =~ /^null/o; $1 }, 'NullLiteral';
}

sub StringLiteral {
    bless sub {
        my $chars = shift;
    }, 'StringLiteral';
}

sub RegularExpressionFirstChar {
    bless sub {
        my $chars = shift;
        my $non_term = RegularExpressionNonTerminator->($chars);
        if ($non_term) {
        }
    }, 'RegularExpressionFirstChar';
}

sub RegularExpressionChar {
    bless sub {
    }, 'RegularExpressionChar';
}

sub RegularExpressionTags {
    bless sub { 
        my $chars = shift;
    }, 'RegularExpressionTags';
}

sub RegularExpressionBody {
    bless sub {
        my $chars = shift;
        my $first = RegularExpressionFirstChar->($chars) or return;
        $chars = RegularExpressionChars->($chars) or return;
        $first . $chars;
    }, 'RegularExpressionBody';
}

sub RegularExpressionLiteral {
    bless sub {
        my $chars = shift;
        my $r = qr/^\//o;
        return unless $chars =~ $r;
        my $body = RegularExpressionBody->($chars) or return;
        $chars = substr $chars, 1;
        return unless $chars =~ $r;
        my $flags = RegularExpressionTags->($chars) or return;
        "/$body/$flags";
    }, 'RegularExpressionLiteral';
}

sub Literal {
    bless sub {
        my $chars = shift;
        NullLiteral->($chars)
        || BooleanLiteral->($chars)
        || NumericLiteral->($chars)
        || StringLiteral->($chars)
        || RegularExpressionLiteral->($chars);
    }, 'Literal';
}

sub SignedInteger {
    bless sub {
        my $chars = shift;
        $chars =~ m/^(\+|-)/o;
        my $sign = $1;
        $chars = substr $chars, 1 if $sign;
        my $digits = DecimalDigits->($chars) or return;
        ($sign ? $sign : '') . $digits;
    }, 'SignedInteger';
}

sub ExponentIndicator {
    bless sub { shift =~ /^(e|E)/o; $1 }, 'ExponentIndicator';
}

sub ExponentPart {
    bless sub {
        my $chars = shift;
        my $exp = ExponentIndicator->($chars) or return;
        $chars = substr $chars, length $exp;
        my $int = SignedInteger->($chars) or return;
        $exp . $int;
    }, 'ExponentPart';
}

sub Punctuator {
    my $or = quotemeta join '|', (
        '{', '}', '(', ')', '[', ']', '.', ';', ',', '<',
        '>=', '==', '!=', '===', '+', '-', '*', '%', '<<',
        '>>', '>>>', '&', '!', '~', '&&', '||', '=', '+=',
        '-=', '*=', '>>=', '>>>=', '&=', '|='
        );
    my $r = qr/$or/o;
    bless sub { shift =~ $r; $1 }, 'Punctuator';
}

sub UnicodeDigit {
    bless sub { shift =~ /^(\d+)/o; $1 }, 'UnicodeDigit';
}

sub UnicodeLetter { 
    bless sub { Word->(shift) }, 'UnicodeLetter';
}

sub UnicodeCombiningMark {
    bless sub {
        shift =~ /^[\p{Mn}\p{Mc}]/o; $1;
        }, 'UnicodeCombiningMark';
}

sub UnicodeConnectorPunctuation {
    bless sub {
        shift =~ /^\p{Pc}/o; $1;
        }, 'UnicodeConnectorPunctuation';
}

sub IdentifierStart {
    bless sub {
        my $chars = shift;

        my $letter = UnicodeLetter->($chars);
        return $letter if $letter;

        $chars =~ /^(\$|_)/o;
        return $1 if $1;

        return unless $chars =~ /^\\/o;
        $chars = substr $chars, 1;

        my $seq = UnicodeEscapeSequence->($chars);
        $seq ? "/$seq" : undef;
    }, 'IdentifierStart';
}

sub IdentifierPart {
    bless sub {
        my $chars = shift;

        my $part = IdentifierStart->($chars)
                || UnicodeCombiningMark->($chars)
                || UnicodeDigit->($chars)
                || UnicodeConnectorPunctuation->($chars);
        return $part if $part;

        $chars =~ '\\\\u200C';
        return $1 if $1;

        $chars =~ '\\\\u200D';
        $1;
    }, 'IdentifierPart';
}

sub IdentifierName {
    bless sub {
        my $chars = shift;
        my $start = IdentifierStart->new($chars);
        return $start if $start;
        my $name = &IdenitiferName->($chars) or return;
        my $part = IdentifierPart(substr $chars, length $name);
        $name . $part;
    }, 'IdentifyName';
}

sub Identifier {
    bless sub {
        my $chars = shift;
        return if ReservedWord->($chars);
        IdentifierName->($chars);
    }, 'Identifier';
}

sub Keyword {
    my $or = join '|', (qw(
        break case catch continue debugger default delete
        do else finally for function if in instanceof typeof
        new var return void switch while this with throw try
        ));
    my $r = qr/$or/o;
    bless sub { shift =~ $r; $1 }, 'Keyword';
}

sub FutureReservedWord {
    my $or = join '|', (qw(
        class enum extends super const export import 
        implements let private public interface package 
        protected static yield
        ));
    bless sub {
    }, 'FutureReservedWord';
}

sub ReservedWord {
    bless sub {
        my $chars = shift;
        Keyword->($chars)
        || FutureReservedWord->($chars)
        || NullLiteral->($chars)
        || BooleanLiteral->($chars);
    }, 'ReservedWord';
}

sub Token { 
    bless sub {
        my $chars = shift;
        IdentifierName->($chars)
        || Punctuator->($chars)
        || NumericLiteral->($chars)
        || StringLiteral->($chars);
    }, 'Token';
}

sub DivPunctuator { 
    bless sub {
        my $chars = shift;
        return '/=' if index($chars, '/=') == 0;
        return '/'  if index($chars, '/') == 0;
        undef;
    }, 'DivPunctuator';
}

sub InputElementDiv {
    bless sub {
        my $chars = shift;
        WhiteSpace->($chars)
        || LineTerminator->($chars)
        || Comment->($chars)
        || Token->($chars)
        || DivPunctuator->($chars);
    }, 'InputElementDiv';
}

sub InputElementRegExp {
    bless sub {
        my $chars = shift;
        WhiteSpace->($chars)
        || LineTerminator->($chars)
        || Comment->($chars)
        || Token->($chars)
        || RegularExpressionLiteral->($chars);
    } , 'InputElementRegExp';
}

1;
