package JBD::Javascript;
# ABSTRACT: provides Javascript parsing subs
# VERSION

# Javascript parsing subs.
# @author Joel Dalley
# @version 2014/Apr/13

use JBD::Core::Exporter ':omni';

use JBD::Parser::DSL;
use JBD::Javascript::Lexers;
use JBD::Javascript::Grammar;
use JBD::Javascript::Transformers 'remove_novalue';

# @param string $parser A JBD::Parser sub name.
# @param scalar/ref $text Javascript text.
# @return arrayref Array of JBD::Parser::Tokens.
sub std_parse(@) {
    my ($parser, $text) = @_;

    init;
    my $st = parser_state tokens $text, [];

    no strict 'refs';
    remove_novalue &$parser->($st) or die $st->error_string;
}

1;
