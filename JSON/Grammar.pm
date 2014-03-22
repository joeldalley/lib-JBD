
# A JSON grammar.
# @author Joel Dalley
# @version 2014/Mar/18

package JBD::JSON::Grammar;

use JBD::Core::Exporter;

use JBD::JSON::Transformers 'reduce_JsonString';
use JBD::JSON::Lexers;
use JBD::Parser::DSL;

our @EXPORT = qw(init
    json_member_list json_element_list
    json_bool_literal json_null_literal
    json_escape_char json_escape_seq
    json_string_char star_string_char
    json_member json_object json_string
    json_array json_value json_text
    );


#///////////////////////////////////////////////////////////////
# Local names. /////////////////////////////////////////////////

sub quote()  { type JsonQuote }
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

sub json_number()       { type JsonNum }
sub json_bool_literal() { true | false }
sub json_null_literal() { null }

sub json_escape_char() { type JsonEscapeChar }
sub json_escape_seq()  { type JsonEscapeSeq }
sub star_escape_seq()  { star json_escape_seq }
sub json_string_char() { 
       colon 
       | comma 
       | type(JsonCurlyBrace) 
       | type(JsonSquareBracket)
       | type(JsonBool)
       | type(JsonNull)
       | json_number
       | type(JsonStringChar)
       | json_escape_seq;
}
sub star_string_char() { star json_string_char }
sub json_string() { 
    trans quote ^ star_string_char ^ quote,
          \&reduce_JsonString;
}

sub star_comma_value()  { star(comma ^ json_value) }
sub json_element_list() { json_value ^ star_comma_value }
sub star_element_list() { star json_element_list }
sub json_array() { 
      star_escape_seq ^ lbrack 
    ^ star_escape_seq ^ star_element_list 
    ^ star_escape_seq ^ rbrack
    ^ star_escape_seq;
}

sub json_member() { 
      star_escape_seq ^ json_string 
    ^ star_escape_seq ^ colon 
    ^ star_escape_seq ^ json_value 
    ^ star_escape_seq;
}
sub star_comma_member() { star(comma ^ json_member) }
sub json_member_list()  { json_member ^ star_comma_member }
sub star_member_list()  { star json_member_list }
sub json_object() { 
      star_escape_seq ^ lbrace
    ^ star_escape_seq ^ star_member_list
    ^ star_escape_seq ^ rbrace;
}

sub json_text() { json_value }


#///////////////////////////////////////////////////////////////
#/ Initialize. /////////////////////////////////////////////////

sub init(%) {
    my %trans = @_;

    my $def = sub {
        no strict 'refs';
        my $sub = shift;
        $trans{$sub} ? trans &$sub, $trans{$sub} : &$sub;
    };

    $JV = star(json_escape_seq)
        ^ ($def->('json_null_literal') |
           $def->('json_bool_literal') |
           $def->('json_number')       |
           $def->('json_string')       |
           $def->('json_array')        |
           $def->('json_object'))
        ^ star(json_escape_seq);
}

1;
