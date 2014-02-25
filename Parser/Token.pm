
# A token.
# @author Joel Dalley
# @version 2014/Feb/23

package JBD::Parser::Token;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';
use JBD::Core::List 'flatmap';

use constant {
    Nothing      => 'Nothing',
    End_of_Input => 'End_of_Input',
};

# @param string $class Object type.
# @param string Token type.
# @param mixed Token value, possibly undef.
# @return JBD::Parser::Token
sub new { 
    my $class = shift;
    bless [@_], $class;
}

# @param string Object type.
# @return JBD::Parser::Token
sub nothing { shift->new(Nothing) }

# @param string Object type.
# @return JBD::Parser::Token
sub end_of_input { shift->new(End_of_Input) }

# @param JBD::Parser::Token
# @return string Token type.
sub type { shift->[0] }

# @param JBD::Parser::Token
# @return array An array with the token's value or values.
sub value { 
    my $val = shift->[1];
    ref $val ? flatmap $val : ($val);
}

# @param JBD::Parser::Token $this
# @param mixed $check A token value.
# @return bool 1 or untrue.
sub ne {
    my ($this, $check) = @_;
    my @check = ref $check ? flatmap @$check : ($check);
    "@{[$this->value]}" ne "@check";
}

# @param JBD::Parser::Token $this
# @param array Zero or more types to check.
# @return bool 1 or undef.
sub typeis { 
    my $t = shift->type;
    for (map ref $_ || $_, @_) { return 1 if $t eq $_ }
    undef;
}

1;
