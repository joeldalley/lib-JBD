
# List utilities.
# @author Joel Dalley
# @version 2014/Feb/05

package JBD::Core::List;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';
use Carp 'croak';


#///////////////////////////////////////////////////////////////
#/ Functional Interface ////////////////////////////////////////

# @param array   an array
# @return array    a shuffled array
sub shuffle(@) {
    my ($j, @l) = (0, @_);
    my $i = @l or return ();
    while (--$i) { $j = int rand $i+1; @l[$i, $j] = @l[$j, $i] }
    @l;
}

# @param array    an array
# @return array    a flat list
sub flatmap(@) { _flatmap_recursive(@_) }

# @param array    an array
# @return array    an array with unique elements
sub uniq(@) { keys %{{map {$_ => undef} @_}} }

# @param array    an array
# @return array    zip-ordered array (1st half, 2nd half)
sub zip(@) { 
    croak 'Odd number of elements in zip' if @_ % 2;
    @_[map {$_, $_ + @_/2} 0 .. (@_/2 - 1)];
}


#///////////////////////////////////////////////////////////////
#/ Used Internally /////////////////////////////////////////////

# Uses recursion to completely flatten the given array.
# @param array    array of arbitrary size, depth and structure
# @return array    a flat list
sub _flatmap_recursive {
    map {
        if    (ref $_ eq 'ARRAY')  { _flatmap_recursive(@$_) }
        elsif (ref $_ eq 'HASH')   { _flatmap_recursive(%$_) }
        elsif (ref $_ eq 'SCALAR') { $$_ }
        else                       { $_ }
    } @_
}

1;
