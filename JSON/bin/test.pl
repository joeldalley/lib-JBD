
use JBD::Parser::DSL;
use JBD::JSON::Grammar;
use JBD::Core::List 'pairsof';

sub get_state($) {
    my $text = shift;
    my @types  = (Quote, JsonEscapeSeq, JsonEscapeChar, JsonStringChar, Num);
    my $tokens = tokens \$text, \@types;
    my $state  = parser_state $tokens;
}

my @cfg = (
    ['json_null_literal', 'null'],
    ['json_bool_literal', 'true'],
    ['json_bool_literal', 'false'],
    ['json_string_char',  'chars'],
    ['star_string_chars',  "String chars?\n"],
    ['json_string',       qq|"This. Is\na string?"|],
    #['json_element_list', '1, 2'],
    #['json_array',        '[1, 2]'],
    ['json_member_list',  '"nada":null'],
    #['json_member_list',  '"one" : 1, "two": [1, 2]'],
    ['json_object',       '{ "one": {"one_A": 1} , "two": 2.0, "tre": 3.0E0 }'],
    );

no strict 'refs';

for my $entry (@cfg) {
    my ($parser, $text) = @$entry;

    my $state  = get_state "$text";
    my $pairs = pairsof lexed  => sub { $state->lexed_tokens }, 
                        parsed => sub { &$parser->($state) or
                                        die $state->error_string };
    
    while (my $pair = $pairs->()) {
        my ($label, $code) = @$pair;
        my @printable = map {
            my ($t, $v) = ($_->type, $_->value);
            $v = "#[\\$1]" if $t =~ /^(JsonEscapeChar|JsonEscapeSeq)$/o;
            $v = defined $v ? $v : 'UNDEF';
            "\n\t$t<$v>";
        } @{$code->()};
        print "[$label] $parser->($text)", join('', @printable), "\n\n";
    }

}
