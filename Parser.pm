
# Parsing primitives.
# @author Joel Dalley
# @version 2014/Feb/22 

package JBD::Parser;

use overload '""' => sub($)  { ref $_[0] || $_[0] },
             '^'  => sub($$) { cat(shift, shift) },
             '|'  => sub($$) { any(shift, shift) };

use JBD::Core::stern;
use JBD::Core::List 'flatmap';
use JBD::Core::Exporter ':omni';
use JBD::Parser::Token qw(token Nothing);

use Carp 'croak';

# @param codref A code block.
# @return JBD::Parser typed coderef.
sub parser(&) { bless $_[0], __PACKAGE__ }

# @param string $type A token type.
# @param mixed $val A token value, possibly undef.
# @return coderef A stack trace printer sub.
sub stack_tracer($$) {
    my ($type, $val) = @_;

    sub {
        my $tok  = defined $_[0] ? shift : 'MISSING';
        my $pval = defined $val ? $val : 'ANY';
        my $args = "Token[$tok], $type\[$pval\]";

        my @trace;
        for (my $i = 0; defined caller($i); $i++) {
            my ($pkg, $line, $sub) = (caller($i))[0, 2, 3];
            my $tab = $i ? ' ' : "\t ";
            push @trace, "$tab pair( $args ) called by "
                       . "$pkg at line $line";
        }
        join "\n", reverse @trace;
    };
}

# @param mixed An object or a string.
# @param mixed Token must match this value.
# @return JBD::Parser typed coderef.
sub pair($$) { 
    my ($type, $value) = (ref $_[0] || $_[0], $_[1]);
    croak 'Token value must be scalar' if ref $value;
    my $tracer = stack_tracer $type, $value;

    # Is the current token of the given type?
    parser {
        my $pst = shift;

        my $token = $pst->current_lexed_token;
        return if !$token || $pst->done_parsing;
        $pst->begin_parse_frame;
        $pst->parse_frame_pair_args($type, $value);
 
        if ($token->typeis($type, Nothing) &&
            (!defined $value || $token->eq($value))) {
            $pst->finish_parse_frame;
            return [$token];
        }
        else {
            $pst->parse_frame_error($tracer->($token));
            return undef;
        }
    };
}

# @param mixed One or more objects / strings.
# @return JBD::Parser typed coderef.
sub type($) { pair shift, undef }

# @param array @p Zero ore more JBD::Parser subs.
# @return JBD::Parser typed coderef.
sub cat(@) {
    my @p = @_;
    return parser {} unless @p;
    #return $p[0] if @p == 1;

    # Do the given N parsers succeed consecutively?
    parser {
        my $pst = shift;
        my @tokens;
        for my $p (@p) {
            my $tokens = $p->($pst) or return;
            push @tokens, flatmap $tokens;
        }
        \@tokens;
    };
}

# @param array @p Zero or more JBD::Parser subs.
# @return JBD::Parser typed coderef.
sub any(@) {
    my @p = @_;
    return parser {} unless @p;
    return $p[0] if @p == 1;

    # Does at least 1 of N given parsers succeed?
    parser {
        my $pst = shift;
        for (@p) {
            my $tokens = $_->($pst);
            return $tokens if $tokens;
        }
        undef;
    };
}

# @param JBD::Parser coderef $p Parser sub.
# @return JBD::Parser typed coderef.
sub star($) {
    my $p = shift;

    my $s; 
    $s = ($p ^ parser {$s->(@_)})
       | parser {[token Nothing]};

    # Nothing type tokens that may have 
    # facilitated a star(*)-like match need 
    # to be removed, before continuing.
    parser {
        my $tokens = $s->(@_) or return;
        [grep !$_->typeis(Nothing), @$tokens];
    };
}

# @param JBD::Parser coderef $p Parser sub.
# @param coderef $trans Token transforming sub.
# @return JBD::Parser typed coderef.
sub trans($$) {
    my ($p, $trans) = @_;

    parser {
        my $pst = shift;
        my $tokens = $p->($pst) or return;
        $trans->($tokens);
    };
}

1; 
