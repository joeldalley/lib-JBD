
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
         parser pair type 
         cat any star trans
    |],
    [qw| JBD::Parser::Token
         token Nothing End_of_Input
    |],
    [qw| JBD::Parser::Lexer
         match tokens input
    |],
    [qw| JBD::Parser::Lexer::Std
         Signed Unsigned Num Int Float
         Word Space Op 
    |],
    );

# @param array Arguments for load().
# @return array Symbols to export.
sub symbols(@) { load shift, @_; @_ }

# Export all symbols in @map.
sub import() {
    my $b = \&JBD::Core::Exporter::bind_to_caller;
    $b->((caller)[0], __PACKAGE__, symbols @$_) for @map;
    JBD::Core::stern->import(1);
}

1;
