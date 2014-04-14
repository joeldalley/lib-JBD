package JBD::Javascript::Lexers;
# ABSTRACT: Javascript lexers
# VERSION

# Javascript Lexers.
# @author Joel Dalley
# @version 2014/Apr/13

use JBD::Core::Exporter;
use JBD::Parser::DSL;

our @EXPORT = qw(
    SourceCharacter WhiteSpace 
    LineTerminator LineTerminatorSequence
    SingleLineCommentChar SingleLineCommentChars
    MultiLineCommentChars PostAsteriskCommentChars
    MultiLineNotAsteriskChar 
    MultiLineNotForwardSlashOrAsteriskChar
    SingleLineComment MultiLineComment Comment
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
            my $post = PostAsteriskCommentChars->(substr $chars, 1);
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

sub Token { bless sub {}, 'Token' }

sub DivPunctuator { bless sub {}, 'DivPunctuator' }

sub RegularExpressionLiteral {
    bless sub {}, 'RegularExpressionLiteral'
}

sub InputElementDiv { bless sub {}, 'InputElementDiv' }

sub InputElementRegExp { bless sub {}, 'InputElementRegExp' }

1;
