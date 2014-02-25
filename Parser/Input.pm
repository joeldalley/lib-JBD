
# Express an array of JBD:Parser::Tokens as a queue,
# so that parsers can easily look ahead and backtrack.
# @author Joel Dalley
# @version 2014/Feb/23

package JBD::Parser::Input;

use JBD::Core::stern;
use JBD::Parser::Token;

use constant {
    TOK => 0,
    CNT => 1, 
    POS => 2,
};

# @param string $type Object type.
# @param arrayref $tokens Array of JBD::Parser::Tokens.
# @return A JBD::Parser::Input.
sub new { 
    my ($type, $tokens) = @_;
    my $fields = [];
    $fields->[TOK] = $tokens;
    $fields->[CNT] = scalar @$tokens;
    $fields->[POS] = 0;
    bless $fields, $type;
}

# @param JBD::Parser::Input
# @return arrayref Array of JBD::Parser::Tokens.
sub tokens { shift->[TOK] }

# @param JBD::Parser::Input $this
# @return string A JBD::Parser::Token.
sub current { 
    my $this = shift;
    $this->[TOK][$this->[POS]];
}

# @param JBD::Parser::Input $this
# @return int Cursor position, after advance.
sub advance_cursor {
    my $this = shift;
    $this->[POS] = $this->num_left 
                 ? $this->[POS] + 1 : $this->[POS];
}

# @param JBD::Parser::Input $this
# @param int $moves Number of moves to retreat.
# @return int Cursor position, after retreat.
sub retreat_cursor {
    my ($this, $moves) = @_;
    $this->[POS] = $this->[POS] > $moves
                 ? $this->[POS] - $moves : 0;
}

# @param JBD::Parser::Input
# @return int Cursor position.
sub cursor { shift->[POS] }

# @param JBD::Parser::Input $this
# @return int Number of JBD::Parser::Tokens left.
sub num_left { 
    my $this = shift;
    $this->[CNT] - $this->[POS];
}

1; 
