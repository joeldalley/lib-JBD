
use JBD::Parser::DSL;
use JBD::JSON::Grammar;

my $text   = shift || '{}';
my @types  = (JsonEscape, Num, Word, Op);
my @tokens = (@{tokens \$text, \@types}, token End_of_Input);
my $state  = parser_state \@tokens;
my $parser = json_object ^ type End_of_Input;
my $parsed = $parser->($state) or die $state->error_string;

puke $parsed;
