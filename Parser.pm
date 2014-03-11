
# Provides parsing primitives.
# @author Joel Dalley
# @version 2014/Feb/22 

package JBD::Parser;

use overload '""' => sub($)  { ref $_[0] || $_[0] },
             '^'  => sub($$) { cat(shift, shift) },
             '|'  => sub($$) { any(shift, shift) };

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';
use JBD::Core::List 'flatmap';
use JBD::Parser::Token qw(token Nothing);
use Carp 'croak';

# @param codref A code block.
# @return JBD::Parser typed coderef.
sub parser(&) { bless $_[0], __PACKAGE__ }

# @param mixed One or more objects / strings.
# @param mixed Token must match this value.
# @return JBD::Parser typed coderef.
sub pair($$) { 
    my $types = ref $_[0] eq 'ARRAY' ? shift : [shift];
    my $value_is = shift;

    croak 'Token value must be scalar' if ref $value_is;

    # Is the current token of one of the given types?
    parser {
        my $pst = shift;

        return if $pst->done_parsing;
        $pst->begin_parse_frame;
        my $token = $pst->current_lexed_token;
        puke {CURRENT => $token, TYPES => $types};

        for my $type (@$types) {
            $type = ref $type || $type;
            print "TYPE: $type\n";
            $pst->add_parse_frame_matcher($type);
            puke $pst;

            # Check for token type / value match. 
            next unless $token->typeis($type, Nothing);
            next if defined $value_is && $token->ne($value_is);
            
            # Success.
            $pst->finish_parse_frame;
            return [$token];
        }

        my $msg = "Unable to parse [$token]";
        $pst->parse_frame_error($msg);
        undef;
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

    # 0 or 1 argument cases:
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

    # Note that any Nothing type tokens that may
    # have facilitated a star(*)-like match need to
    # be removed from $tok, before continuing.
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
