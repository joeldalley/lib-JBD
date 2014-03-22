
# JSON parser token transformers.
# @author Joel Dalley
# @version 2014/Mar/22

package JBD::JSON::Transformers;

use JBD::Core::Exporter ':omni';
use JBD::Parser::DSL;
use JBD::JSON::Lexers;

# @param arrayref Array of JBD::Parser::Tokens.
# @return arrayref Same array, minus Nothing-type tokens.
sub remove_novalue { 
    [grep !$_->typeis(Nothing, JsonEscapeSeq), @{$_[0]}];
}

# @param arrayref Array of JBD::Parser::Tokens.
# @return arrayref A single JsonString-typed token array.
sub reduce_JsonString {
    my $tokens = remove_novalue shift;
    [token 'JsonString', join '', map $_->value, @$tokens];
}

1;
