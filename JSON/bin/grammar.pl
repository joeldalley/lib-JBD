
use JBD::Parser::DSL;
use JBD::Core::List 'pairsof';

use JBD::JSON::Grammar; 

init json_string => \&remove_Nothing,
     json_array  => \&remove_Nothing,
     json_object => \&remove_Nothing;

sub remove_Nothing($) { 
    [grep !$_->typeis(Nothing), @{$_[0]}];
}

sub get_state($) {
    my $text = shift;
    my @types  = (
        Num, 
        JsonQuote,
        JsonComma,
        JsonColon,
        JsonCurlyBrace,
        JsonSquareBracket,
        JsonEscapeSeq,
        JsonEscapeChar, 
        JsonStringChar,
        );
    my $tokens = tokens \$text, \@types;
    my $state  = parser_state $tokens;
}

my @cfg = (
    ['json_null_literal', 'null'],
    ['json_bool_literal', 'true'],
    ['json_bool_literal', 'false'],
    ['json_string_char',  'chars'],
    ['star_string_chars',  "String chars?\n"],
    ['json_string',       qq|"This. Is\na string?\r\f"|],
    ['json_member_list',  '"nada":null'],
    ['json_value',        '1'],
    ['json_element_list', '1, 2'],
    ['json_array',        '[1, 2]'],
    ['json_member_list',  '"one" : 1, "two": [1, 2]'],
    ['json_object',       '{ "one": {"one_A": 1} , ' .
                          '  "two": 2.0, "tre": 3.0E0 }'],
    );

for my $entry (@cfg) {
    my ($parser, $text) = @$entry;
    my $state  = get_state "$text";

    my $pairs = pairsof 
                    #LEXED  => sub { $state->lexed_tokens },
                    PARSED => sub {
                         no strict 'refs';
                         my $parsed = &$parser->($state) 
                             or die $state->error_string;
                         remove_Nothing $parsed;
                    };
    
    while (my $pair = $pairs->()) {
        my ($label, $code) = @$pair;

        my @printable = map {
            my ($t, $v) = ($_->type, $_->value);
            printable_representation_of_whitespace: {
                my $r = qr/^(JsonEscapeChar|JsonEscapeSeq)$/o;
                $v = "#[\\$1]" if $t =~ $r;
            }
            $v = defined $v ? $v : 'UNDEF';
            "\n\t$t<$v>";
        } @{$code->()};

        print "[$label] $parser->($text)", 
              join('', @printable), "\n\n";
    }

}
