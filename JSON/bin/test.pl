
use JBD::Parser::DSL;
use JBD::JSON::Grammar;

sub get_state($) {
    my $text = shift;
    my @types  = (JsonEscape, Num, JsonStringChars, Op);
    my $tokens = tokens \$text, \@types;
    my $state  = parser_state $tokens;
}

my @cfg = (
    ['json_null_literal', 'null'],
    ['json_bool_literal', 'true'],
    ['json_bool_literal', 'false'],
    ['json_esc_sequence', "\n\t\r"],
    ['json_esc_sequence', '\uFFFF'],
    ['json_string_chars', 'chars'],
    ['json_string',       '"This. Is; a string?"'],
    ['json_element_list', '1, 2'],
    ['json_array',        '[1, 2]'],
    ['json_member_list',  '"nada":null'],
    ['json_member_list',  '"one" : 1, "two": [1, 2]'],
    ['json_object',       '{ "one": {"one_A": 1} , "two": 2.0, "tre": 3.0E0 }'],
    );

no strict 'refs';

for my $entry (@cfg) {
    my ($parser, $text) = @$entry;

    my $state  = get_state "$text";
    my $parsed = &$parser->($state)
                 or die $state->error_string;

    print "$parser->($text)",
          join(',', 
              map {
                  my ($t, $v) = ($_->type, $_->value);
                  my $m = JsonEscape->($v) if defined $v;
                  $v = $m ? '\\JsonEscape' : $_->value;
                  $v = defined $v ? $v : 'UNDEF';
                  "\n\t$t<$v>";
              } @$parsed
          ), "\n\n";

}
