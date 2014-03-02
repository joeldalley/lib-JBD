
#/ Warnings and strict.
#/ @author Joel Dalley
#/ @version 2013/Oct/26

package JBD::Core::stern;

use strict;
use warnings;
use Data::Dumper();

sub puke {
    my $chunks = @_ > 1 ? [@_] : shift;
    print Data::Dumper::Dumper $chunks;
}

sub barf { puke @_; exit }

sub import {
    shift if (ref $_[0] || $_[0] || '') eq __PACKAGE__;

    no strict 'refs';
    my $depth = shift || 0;
    *{(caller($depth))[0] ."::$_"} = *$_ for qw(puke barf);

    warnings->import;
    strict->import;
}

1;
