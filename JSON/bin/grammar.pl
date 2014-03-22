
# Basic grammar driver.
# @author Joel Dalley
# @version 2014/Mar/21

use JBD::Core::List 'pairsof';
use JBD::Core::File 'read';

use JBD::Parser::DSL;
use JBD::JSON::Grammar; 
use JBD::JSON::Lexers;

init json_string => \&remove_Nothing,
     json_array  => \&remove_Nothing,
     json_object => \&remove_Nothing;


# Optionally specify a single json_corpus file to test.
# If no argument, then all inline & corpus tests run.
my $file = shift;

# Inline tests.
my @cfg = $file ? () : (
    ['json_escape_seq',   '\\"'],
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

# Corpus tests.
push @cfg, ['json_object', $_], for corpus_texts($file);

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
    
    binmode STDOUT, ':utf8';
    while (my $pair = $pairs->()) {
        my ($label, $code, $n) = (@$pair, 0);
        print "$label $parser->($text)";
        for my $token (@{$code->()}) {
            print "\n\t[", ++$n, '] ', to_str($token)
        }
        print "\n\n";
    }
}


exit;
####


# @param string [opt] A single file to return text for.
# @return array Array of strings to JSON corpus texts.
sub corpus_texts { 
    my $pattern = $_[0] ? $_[0] : 'json_corpus/*.json';

    map {
        $_ = read($_); 
        $_ =~ s{\R}{}g; 
        $_ =~ s{\s}{}g;
        $_;
    } glob $pattern;
}

# @param arrayref Array of JBD::Parser::Tokens.
# @return arrayref Same array, minus Nothing-type tokens.
sub remove_Nothing { [grep !$_->typeis(Nothing), @{$_[0]}] }

# @param string Input text.
# @return JBD::Parser::State
sub get_state {
    parser_state tokens \+shift, [
        JsonNum,       JsonQuote,      JsonComma, 
        JsonColon,     JsonCurlyBrace, JsonSquareBracket,
        JsonEscapeSeq, JsonBool,       JsonNull,
        JsonStringChar
    ];
}

# @param JBD::Parser::Token A token.
# @return string Token representation, for printing.
sub to_str {
    my $t = $_[0]->type;
    my $v = defined $_[0]->value ? $_[0]->value : 'UNDEF';

    FORMAT_WHITESPACE: {
        my $r = qr/^(JsonEscape\w+)$/o;
        $v = "#[\\$1]" if $t =~ $r;
    }

    "$t<$v>";
}
