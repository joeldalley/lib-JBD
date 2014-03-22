
# JSON parsing subs.
# @author Joel Dalley
# @version 2014/Mar/22

package JBD::JSON;

use JBD::Core::Exporter ':omni';

use JBD::Parser::DSL;
use JBD::JSON::Lexers;
use JBD::JSON::Grammar;
use JBD::JSON::Transformers 'remove_Nothing';

# @param string $parser A JBD::Parser sub name.
# @param scalar/ref $text JSON text.
# @return arrayref Array of JBD::Parser::Tokens.
sub std_parse(@) {
    my ($parser, $text) = @_;

    init json_array  => \&remove_Nothing,
         json_object => \&remove_Nothing;

    my $st = parser_state tokens $text, [
        JsonNum,       JsonQuote,      JsonComma,
        JsonColon,     JsonCurlyBrace, JsonSquareBracket,
        JsonEscapeSeq, JsonBool,       JsonNull,
        JsonStringChar
    ];

    no strict 'refs';
    remove_Nothing &$parser->($st) or die $st->error_string;
}

1;
