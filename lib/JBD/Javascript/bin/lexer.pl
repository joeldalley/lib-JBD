
# Basic lexer driver.
# @author Joel Dalley
# @version 2014/Apr/14

use lib '../../../'; # Needed for development.

use utf8;
use JBD::Parser::DSL;
use JBD::Javascript::Lexers qw(LineTerminator LineTerminatorSequence Comment UnicodeDigit);

my $js;

$js = <<JS;

/*
 * Comment1.
 */

// Comment2.

۲
JS

my $tokens = tokens \$js, [
    LineTerminator, LineTerminatorSequence,
    Comment, UnicodeDigit
];

puke $tokens;
