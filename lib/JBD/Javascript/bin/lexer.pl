
# Basic lexer driver.
# @author Joel Dalley
# @version 2014/Apr/14

use lib '../../../'; # Needed for development.

use JBD::Parser::DSL;
use JBD::Javascript::Lexers;

my $js;

$js = <<JS;

/*
 * Comment1.
 */

// Comment2.
JS

my $tokens = tokens \$js, [ 
    LineTerminator, LineTerminatorSequence,
    Comment
];

puke $tokens;
