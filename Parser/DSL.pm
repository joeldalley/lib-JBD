
# Provides an import sub that exports everything in @map.
# @author Joel Dalley
# @version 2014/Feb/23

package JBD::Parser::DSL;

use JBD::Core::stern;
use JBD::Core::Exporter ();

use Module::Load 'load';

# Packages and their symbols.
my @map = (
    [qw| JBD::Parser 
         parser is cat any star trans
         mapis mapcat mapany 
    |],
    [qw| JBD::Parser::Token
         Nothing End_of_Input
    |],
    [qw| JBD::Parser::Lexer
         tokens input
    |],
    [qw| JBD::Parser::Lexer::Std
         Word Space Op Int Float Ratio Dot
    |],
    );

# @param array Arguments for load().
# @return array Symbols to export.
sub symbols(@) { load shift, @_; @_ }

# Export all symbols in @map.
sub import() {
    JBD::Core::stern->import;
    my $b = \&JBD::Core::Exporter::bind_to_caller;
    $b->((caller)[0], __PACKAGE__, symbols @$_) for @map;
}

1;
