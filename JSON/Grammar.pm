
# A JSON grammar.
# @author Joel Dalley
# @version 2014/Mar/18

package JBD::JSON::Grammar;

use constant export_matchers => qw(
    JsonQuote JsonColon JsonComma
    JsonCurlyBrace JsonSquareBracket
    JsonNum JsonNull JsonBool 
    JsonStringChar JsonEscapeSeq 
    UnicodeEscapeSeq JsonEscapeChar 
    );
use constant export_parsers => qw(
    json_member_list json_element_list
    json_bool_literal json_null_literal
    json_escape_char json_escape_seq
    json_string_char star_string_chars
    json_member json_object json_string
    json_array json_value json_text
    );
our @EXPORT = ('init', export_matchers, export_parsers);

use JBD::Parser::DSL;
use JBD::Core::Exporter;


#///////////////////////////////////////////////////////////////
# Local matchers. //////////////////////////////////////////////

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
        $chars =~ /^(\R)/o; $1;
    }, 'JsonEscapeChar';
}

sub JsonEscapeSeq {
    bless sub {
        my $chars = shift;
        JsonEscapeChar->($chars) || UnicodeEscapeSeq->($chars);
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


#///////////////////////////////////////////////////////////////
# Local names. /////////////////////////////////////////////////

sub quote()  { type JsonQuote }
sub str($)   { pair JsonStringChar, shift }
sub colon()  { pair JsonColon, ':' }
sub comma()  { pair JsonComma, ',' }
sub lbrace() { pair JsonCurlyBrace, '{' }
sub rbrace() { pair JsonCurlyBrace, '}' }
sub lbrack() { pair JsonSquareBracket, '[' }
sub rbrack() { pair JsonSquareBracket, ']' }
sub true()   { pair JsonBool, 'true' }
sub false()  { pair JsonBool, 'false' }
sub null()   { pair JsonNull, 'null' }


#///////////////////////////////////////////////////////////////
# Grammatical productions. /////////////////////////////////////

my $JV; 
my $json_value = parser {$JV->(@_)};
sub json_value() { $json_value }

sub json_bool_literal() { true | false }
sub json_null_literal() { null }

sub json_escape_char    { type JsonEscapeChar }
sub json_escape_seq     { type JsonEscapeSeq }
sub json_string_char()  { type JsonStringChar }
sub star_string_chars() {
    star(json_string_char) 
    ^ star(json_string_char 
         | json_escape_seq 
         | json_escape_char)
}
sub json_string() { quote ^ star_string_chars ^ quote }

sub star_comma_value()  { star(comma ^ json_value) }
sub json_element_list() { json_value ^ star_comma_value }
sub star_element_list() { star json_element_list }
sub json_array()        { lbrack ^ star_element_list ^ rbrack }

sub json_member()       { json_string ^ colon ^ json_value }
sub star_comma_member() { star(comma ^ json_member) }
sub json_member_list()  { json_member ^ star_comma_member }
sub star_member_list()  { star json_member_list }
sub json_object()       { lbrace ^ star_member_list ^ rbrace }

sub json_number()       { type JsonNum }
sub json_text()         { json_value }

sub init(%) {
    my %trans = @_;

    my $def = sub {
        no strict 'refs';
        my $sub = shift;
        $trans{$sub} ? trans &$sub, $trans{$sub} : &$sub;
    };

    $JV = $def->('json_null_literal')
        | $def->('json_bool_literal')
        | $def->('json_number')
        | $def->('json_string')
        | $def->('json_array')
        | $def->('json_object');
}

1;
