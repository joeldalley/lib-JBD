
use JBD::Parser::DSL;
use JBD::JSON::Grammar;

sub get_state($) {
    my $text = shift;
    my @types  = (JsonEscape, Op, Num, JsonStringChar);
    my $tokens = tokens \$text, \@types;
    my $state  = parser_state $tokens;
}

my @cfg = (
    ['json_null_literal', 'null'],
    ['json_bool_literal', 'true'],
    ['json_bool_literal', 'false'],
    ['json_esc_sequence', "\n\r\t"],
    ['json_esc_sequence', '\uFFFF'],
    ['json_string_chars', 'chars'],
    );

no strict 'refs';

for my $entry (@cfg) {
    my ($parser, $text) = @$entry;

    my $state  = get_state "$text";
    my $parsed = &$parser->($state)
                 or die $state->error_string;

    print "\n", $parser->($text), "\t",
          join(',', map "[$_]", @$parsed), "\n";

}
