
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
use JBD::Parser::Input;
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
        my $in = shift;
        my $tok = $in->current or return;

        for my $type (@$types) {
            # If $type is a string, then its value stays.
            # If $type is an object, update to object's type.
            $type = ref $type || $type;

            # Check for token type / value match. 
            next unless $tok->typeis($type, Nothing);
            next if defined $value_is && $tok->ne($value_is);
            
            # Success.
            my $pos = $in->advance_cursor;
            return ([$tok], $in);
        }
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
        my $in = shift;
        my ($moves, @tok) = (0, ());

        for my $p (@p) {
            my ($tok) = $p->($in);

            if (defined $tok) {
                my @flat = flatmap $tok;
                push @tok, @flat;
                $moves += @flat;
                next;
            }

            $in->retreat_cursor($moves) if $moves;
            return;
        }
        (\@tok, $in);
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
        my $in = shift;
        for (@p) {
            my ($tok) = $_->($in);
            return ($tok, $in) if defined $tok;
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
       | parser {(token Nothing)};

    # Note that any Nothing type tokens that may
    # have facilitated a star(*)-like match need to
    # be removed from $tok, before continuing.
    parser {
        my ($tok, $in) = $s->(@_);
        $tok = ref $tok eq 'ARRAY' ? $tok : [$tok];
        $tok = [grep !$_->typeis(Nothing), @$tok];
        ($tok, $in);
    };
}

# @param JBD::Parser coderef $p Parser sub.
# @param coderef $trans Token transforming sub.
# @return JBD::Parser typed coderef.
sub trans($$) {
    my ($p, $trans) = @_;

    parser {
        my $in = shift;
        my ($tok) = $p->($in);
        return unless defined $tok;
        ($trans->($tok), $in);
    };
}

1; 
