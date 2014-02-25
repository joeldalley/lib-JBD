
# Provides import().
# In particular, ':omni' has been useful a pragma.
# @author Joel Dalley
# @version 2014/Feb/22

package JBD::Core::Exporter;

use JBD::Core::stern;
no strict 'refs';

use constant MODES => (
    ':omni',
    ':default',
    );

# Modally, applies the requested import sub to calling package.
sub import {
    shift if (ref $_[0] || $_[0] || '') eq __PACKAGE__;
    my $m = shift || ':default';
    my $s = (map {s/^:/_/; $_} grep $m eq $_, MODES)[0];
    *{"${\(caller)[0]}::import"} = *{__PACKAGE__ . "::$s"};
}


#///////////////////////////////////////////////////////////////
#/ Utilties ////////////////////////////////////////////////////

# Bind exporting package symbols to calling package.
# @param string $c    Calling package.
# @param string $p    Exporting package.
# @param array    Symbols $c will import from $p.
sub bind_to_caller($$;@) {
    my ($c, $p) = (shift, shift);
    *{"${c}::$_"} = *{"${p}::$_"} for grep $p->can($_), @_;
}


#///////////////////////////////////////////////////////////////
#/ Import subs /////////////////////////////////////////////////

# @param string $p    Exporting package.
# @param array    Symbols caller will import from $p.
sub _omni($;@) { 
    my $p = shift;
    bind_to_caller((caller)[0], $p, @_);
}

# @param string $p    Exporting package.
# @param array    Symbols caller will import from $p.
sub _default($;@) {
    my $p = shift;
    if (!@_ && defined *{"${p}::EXPORT"}{ARRAY}) {
        my $ref = *{"${p}::EXPORT"};
        bind_to_caller((caller)[0], $p, @$ref);
    }
    if (@_ && defined *{"${p}::EXPORT_OK"}{ARRAY}) {
        my $ref = *{"${p}::EXPORT_OK"};
        my @ok = grep index("@$ref", $_) >= 0, @_;
        bind_to_caller((caller)[0], $p, @ok);
    }
} 

1;
