
# A JSON grammar.
# @author Joel Dalley
# @version 2014/Mar/18

package JBD::JSON::Grammar;

use constant export_matchers => qw(
    JsonStringChars
    JsonEscape
    );
use constant export_parsers => qw(
    json_member_list
    json_element_list
    json_string_chars
    json_esc_sequence
    json_bool_literal
    json_null_literal
    json_member
    json_object
    json_string
    json_array
    json_value
    json_text
    );
our @EXPORT = (export_matchers, export_parsers);

use JBD::Parser::DSL;
use JBD::Core::Exporter;


#///////////////////////////////////////////////////////////////
# Local matchers. //////////////////////////////////////////////

sub JsonEscape { 
    my $r = qr/(\R|[[:xdigit:]]{4})/o;
    bless sub {shift =~ $r; $1}, 'JsonEscape';
}

sub JsonStringChars {
    bless sub {
        my $chars = shift;
        return unless defined $chars;
        return if grep substr($chars, 0, 1) eq $_, ('"', '\\');
        return if $chars =~ /^[[:xdigit:]]{4}$/o
               && (hex "0x$1" >= 0 || hex "0x$1" <= 0x001F);
        Word->($chars) || Op->($chars);
    }, 'JsonStringChars';
}


#///////////////////////////////////////////////////////////////
# Local names. /////////////////////////////////////////////////

sub quote()  { pair Op, '"' }
sub str($)   { pair JsonStringChars, shift }
sub colon()  { str ':' }
sub comma()  { str ',' }
sub lbrace() { str '{' }
sub rbrace() { str '}' }
sub lbrack() { str '[' }
sub rbrack() { str ']' }


#///////////////////////////////////////////////////////////////
# Grammatical productions. /////////////////////////////////////

my $JV; 
my $json_value = parser {$JV->(@_)};
sub json_value() { $json_value }

sub json_bool_literal() { str 'true' | str 'false' }
sub json_null_literal() { str 'null' }
sub json_whitespace()   { type Space }
sub json_number()       { type Num }
sub json_esc()          { type JsonEscape }
sub json_esc_sequence() { star json_esc }

sub json_string_chars() { type JsonStringChars }
sub star_string_chars() { star json_string_chars }
sub json_string()       { quote ^ star_string_chars ^ quote }

sub star_comma_value()  { star(comma ^ json_value) }
sub json_element_list() { json_value ^ star_comma_value }
sub star_element_list() { star json_element_list }
sub json_array()        { lbrack ^ star_element_list ^ rbrack }

sub json_member()       { json_string ^ colon ^ json_value }
sub star_comma_member() { star(comma ^ json_member) }
sub json_member_list()  { json_member ^ star_comma_member }
sub star_member_list()  { star json_member_list }
sub json_object()       { lbrace ^ star_member_list ^ rbrace }

sub json_text()         { json_value }

$JV = json_null_literal
    | json_bool_literal
    | json_number
    | json_string
    | json_array
    | json_object;

1;
