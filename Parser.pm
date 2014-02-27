
# Provides parsing primitives.
# @author Joel Dalley
# @version 2014/Feb/22 

package JBD::Parser;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';
use JBD::Core::List 'flatmap';

use JBD::Parser::Lexer::Std 'Word';
use JBD::Parser::Token 'Nothing';
use JBD::Parser::Input;
use Carp 'croak';

# @param codref A code block.
# @return JBD::Parser typed coderef.
sub parser(&) { bless $_[0], __PACKAGE__ }

# @param mixed $types One or more objects / strings.
# @param mixed [opt] $value_is Token must match this value.
# @return JBD::Parser typed coderef.
sub is($;$) {
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

# @param array Map of {Parser sub => token value}.
# @return array Array of is(Type, Value) JBD::Parser subs.
sub mapis(@) { 
    croak 'Missing {Type => Value} map, for is()' unless @_;
    croak 'Uneven number in given map' if @_ % 2;
    my @is; while (@_) { push @is, is shift, shift } @is;
}

# mapp() -- 2nd "p" for Parser.
# @param JBD::Parser coderef $p Mapping sub.
# @param array Map of {Parser sub => token value}.
# @return JBD::Parser typed coderef.
sub mapp(&@) { my $p = shift; $p->(mapis @_) }

# @param array Map of {Parser sub => token value}.
# @return JBD::Parser typed coderef.
sub mapcat(@) { mapp \&cat, @_ }

# @param array Map of {Parser sub => token value}.
# @return JBD::Parser typed coderef.
sub mapany(@) { mapp \&any, @_ }

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

    my $null = parser {(JBD::Parser::Token->nothing)};
    my $s; $s = any cat($p, parser {$s->(@_)}), $null;

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
