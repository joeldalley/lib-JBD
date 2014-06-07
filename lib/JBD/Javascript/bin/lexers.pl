
# Basic lexer driver.
# @author Joel Dalley
# @version 2014/Apr/14
# @version 2014/Jun/02 - rewrite to use external Javascript corpus.

use lib '../../../'; # Needed for development.

use JBD::Parser::DSL;
use JBD::Javascript::Lexers;

use File::Slurp 'read_file';
use JBD::Core::List 'pairsof';

my $only_test = shift;

my %cfg = (
    'comments.js' => [
        LineTerminator, LineTerminatorSequence, Comment
        ],
    'digits.js' => [
        WhiteSpace, DecimalLiteral, HexIntegerLiteral, 
        DecimalIntegerLiteral, ExponentPart, SignedInteger
        ],
    'boolean_and_null.js' => [
        WhiteSpace, BooleanLiteral, NullLiteral
        ],
    );

%cfg = ($only_test => $cfg{$only_test}) 
    if $only_test && exists $cfg{$only_test};

while (my ($file, $lexers) = each %cfg) {
    my $js     = read_file "javascript_corpus/$file";
    my $tokens = tokens $js, $lexers;

    print "\nTokenized file: $file\n";
    puke $tokens;
}
