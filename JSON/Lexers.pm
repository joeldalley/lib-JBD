
# JSON Lexers.
# @author Joel Dalley
# @version 2014/Mar/22

package JBD::JSON::Lexers;

use JBD::Core::Exporter;
use JBD::Parser::DSL;

our @EXPORT = qw(
    JsonNum JsonNull JsonBool 
    JsonSquareBracket JsonCurlyBrace 
    JsonColon JsonComma JsonQuote JsonStringChar 
    JsonEscapeSeq UnicodeEscapeSeq JsonEscapeChar 
    );

sub UnicodeEscapeSeq {
    bless sub {
        my $chars = shift;
        $chars =~ qr/^[[:xdigit:]]{4}/o;
        return if !defined $1
               || hex "0x$1" < 0 
               || hex "0x$1" > 0x001F; $1;
    }, 'UnicodeEscapeSeq';
}

sub JsonEscapeChar { 
    bless sub {
        my $chars = shift;
        return unless length $chars;

        $chars =~ /^(\R)/o; 
        return $1 if defined $1;

        (Op->($chars) || '') eq '\\' && do {
            $chars =~ /^(\\)("|\\|b|f|n|r|t)/o;
            return "$1$2" if defined $1 && defined $2;
        };
    }, 'JsonEscapeChar';
}

sub JsonEscapeSeq {
    bless sub {
        my $chars = shift;
        JsonEscapeChar->($chars) 
        || UnicodeEscapeSeq->($chars);
    }, 'JsonEscapeSeq';
}

sub JsonOp {
    bless sub {
        my $chars = shift;
        my $op = Op->($chars);
        $op && $op ne '\\' && $op ne '"' ? $op : undef;
    }, 'JsonOp';
}

sub JsonQuote { 
    bless sub {
        my $chars = shift;
        my $op = Op->($chars);
        $op && $op eq '"' ? $op : undef;
    }, 'JsonQuote';
}

sub JsonColon {
    bless sub {
        my $chars = shift;
        my $op = Op->($chars);
        $op && $op eq ':' ? $op : undef;
    }, 'JsonColon';
}

sub JsonComma {
    bless sub {
        my $chars = shift;
        my $op = Op->($chars);
        $op && $op eq ',' ? $op : undef;
    }, 'JsonComma';
}

sub JsonCurlyBrace {
    bless sub {
        my $chars = shift;
        my $op = Op->($chars);
        $op && ($op eq '{' || $op eq '}') ? $op : undef;
    }, 'JsonCurlyBrace';
}

sub JsonSquareBracket {
    bless sub {
        my $chars = shift;
        my $op = Op->($chars);
        $op && ($op eq '[' || $op eq ']') ? $op : undef;
    }, 'JsonSquareBracket';
}

sub JsonNum { bless sub { Num->(@_) }, 'JsonNum' }

sub JsonBool {
    bless sub {
        my $chars = shift;
        return unless defined $chars;
        $chars =~ /^(true|false)/o; $1;
    }, 'JsonBool';
}

sub JsonNull {
    bless sub {
        my $chars = shift;
        return unless defined $chars;
        index($chars, 'null') == 0 ? 'null' : undef;
    }, 'JsonNull';
}

sub JsonStringChar {
    bless sub {
        my $chars = shift;
        return unless defined $chars;
        return if substr($chars, 0, 1) eq '"';
        Word->($chars) || JsonOp->($chars);
    }, 'JsonStringChar';
}

1;
