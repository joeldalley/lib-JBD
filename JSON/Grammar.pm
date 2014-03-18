
# A JSON grammar.
# @author Joel Dalley
# @version 2014/Mar/18

package JBD::JSON::Grammar;

use constant export_matchers => qw(
    JsonEscape
    );
use constant export_parsers => qw(
    json_object
    json_value
    json_text
    );
our @EXPORT = (export_matchers, export_parsers);

use JBD::Parser::DSL;
use JBD::Core::Exporter;


# Local matchers.
sub JsonEscape { 
    bless sub {
        my $r1 = qr/\\b|\\f|\\n|\\r|\\t/o;
        my $r2 = qr/\\u[a-f0-9]{4}/io;
        shift =~ qr/($r1|$r2)/o; $1;
    }, 'JsonEscape';
}


# Local names.
sub esc()    { type JsonEscape }
sub op($)    { pair Op, shift }
sub word($)  { pair Word, shift }
sub quote()  { op '"' }
sub lbrace() { op '{' }
sub rbrace() { op '}' }
sub lbrack() { op '[' }
sub rbrack() { op ']' }


# Grammatical productions:
my $JV; 
my $json_value = parser {$JV->(@_)};
sub json_value() { $JV }

sub json_text()         { json_value }
sub json_esc_sequence() { star esc }
sub json_whitespace()   { type Space }
sub json_number()       { type Num }
sub json_string_chars() { type Word }
sub star_string_chars() { star json_string_chars }
sub json_string()       { quote ^ star_string_chars ^ quote }
sub json_bool_literal() { word 'true' | word 'false' }
sub json_null_literal() { word 'null' }

sub json_element_list() { json_value ^ star(json_value) }
sub star_element_list() { star json_element_list }
sub json_array()        { lbrack ^ star_element_list ^ rbrack }

sub json_member()       { json_string ^ json_value }
sub json_member_list()  { json_member ^ star(json_member) }
sub star_member_list()  { star json_member_list }
sub json_object()       { lbrace ^ star_member_list ^ rbrace }

$JV = sub { 
      json_null_literal
    | json_bool_literal
    | json_object
    | json_array
    | json_string
    | json_number
};

1;
