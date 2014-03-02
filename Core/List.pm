
# List utilities.
# @author Joel Dalley
# @version 2014/Feb/05

package JBD::Core::List;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';
use Carp 'croak';


# @param array an array
# @return array a flat list
sub flatmap(@) { 
    map {
        if    (ref $_ eq 'ARRAY')  { flatmap(@$_) }
        elsif (ref $_ eq 'HASH')   { flatmap(%$_) }
        elsif (ref $_ eq 'SCALAR') { $$_ }
        else                       { $_ }
    } @_
}

# @param array An array.
# @return array An array with unique elements.
sub uniq(@) { keys %{{map {$_ => undef} @_}} }

# @param array An array.
# @return array A shuffled array.
sub shuffle(@) {
    my ($j, @l) = (0, @_);
    my $i = @l or return ();
    while (--$i) { $j = int rand $i+1; @l[$i, $j] = @l[$j, $i] }
    @l;
}

# @param array An even-sized array.
# @return array A zip-ordered array (1st half, 2nd half).
sub zip(@) { 
    croak 'Odd number of elements in zip' if @_ % 2;
    @_[map {$_, $_ + @_/2} 0 .. (@_/2 - 1)];
}

# @param array An even-sized array.
# @return coderef An iterator of pairs from the array.
sub pairsof(@) {
    croak 'Odd number of elements in pairsof' if @_ % 2;
    my @L = @_; sub {@L ? [shift @L, shift @L] : undef};
}

1;
