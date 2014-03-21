
# Basic grammar driver.
# @author Joel Dalley
# @version 2014/Mar/21

use JBD::Parser::DSL;
use JBD::Core::List 'pairsof';
use JBD::JSON::Grammar; 

init json_string => \&remove_Nothing,
     json_array  => \&remove_Nothing,
     json_object => \&remove_Nothing;

my @cfg = (
    ['json_null_literal', 'null'],
    ['json_bool_literal', 'true'],
    ['json_bool_literal', 'false'],
    ['json_string_char',  'chars'],
    ['star_string_chars', "String chars?\n"],
    ['json_string',       qq|"This. Is\na string?\r\f"|],
    ['json_member_list',  '"nada":null'],
    ['json_element_list', 'true, false, null, 1, 2'],
    ['json_array',        '[1, 2]'],
    ['json_member_list',  '"one" : 1, "two": [1, 2]'],
    ['json_object',       '{ "one": {"one_A": true} , ' .
                          '  "two": 2.0, "tre": 3.0E0 }'], 
    );

for my $entry (@cfg) {
    my ($parser, $text) = @$entry;
    my $state = get_state("$text");

    # Optionally show lexed tokens as 
    # well, which helps in debugging.
    my $pairs = pairsof 
        #LEXED  => sub { $state->lexed_tokens },
        PARSED => sub {
             no strict 'refs';
             my $parsed = &$parser->($state) 
                 or die $state->error_string;
             remove_Nothing($parsed);
        };
    
    while (my $pair = $pairs->()) {
        my ($label, $code) = @$pair;

        my $report = '';
        for (@{$code->()}) {
            my ($t, $v) = _type_and_value($_);
            $report .= "\n\t" . "$t<$v>";
        }

        print "[$label] $parser->($text) $report\n\n";
    }

}


#####
exit;
#####


# @param arrayref Array of JBD::Parser::Tokens.
# @return arrayref Same array, minus Nothing-type tokens.
sub remove_Nothing { 
    [grep !$_->typeis(Nothing), @{$_[0]}];
}

# @param string $text Input text.
# @return JBD::Parser::State
sub get_state {
    my $text = shift;
    my @types  = (
        JsonNum,       JsonQuote,      JsonComma, 
        JsonColon,     JsonCurlyBrace, JsonSquareBracket,
        JsonEscapeSeq, JsonEscapeChar, JsonBool, 
        JsonNull,      JsonStringChar,
        );
    parser_state tokens \$text, \@types;
}

# @param JBD::Parser::Token A token.
# @return array Array of (type, value).
sub _type_and_value {
    my $t = $_[0]->type;
    my $v = defined $_[0]->value ? $_[0]->value : 'UNDEF';

    FORMAT_WHITESPACE: {
        my $r = qr/^(JsonEscape\w+)$/o;
        $v = "#[\\$1]" if $t =~ $r;
    }

    ($t, $v);
}
