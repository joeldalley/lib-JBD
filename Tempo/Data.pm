
# Tempo run data object.
# @author Joel Dalley
# @version 2013/Nov/16

package JBD::Tempo::Data;

use JBD::Core::stern;
use JBD::Core::Storable;

use Exporter 'import';
our @EXPORT_OK = qw(DATE DIST SURF FOOT);

# names for data field array indexes
sub DATE {0}    sub DIST {1}
sub SURF {2}    sub FOOT {3}


#//////////////////////////////////////////////////////////////
# Object Interface ////////////////////////////////////////////

# @param string $type   object type
# @param string $store    path to Storable file
# @return JBD::Tempo::Data
sub new {
    my ($type, $store) = @_;
    bless [JBD::Core::Storable->new($store)], $type;
}

# @param JBD::Tempo::Data
# @return JBD::Core::Storable
sub store { shift->[0] }

# @param JBD::Tempo::Data
# @return arrayref    run data
sub load { shift->store->load }

# @param JBD::Tempo::Data
# @return array    a copy of Storable data
sub copy { @{shift->load} }


# @param JBD::Tempo::Data
# @param coderef [optional]    filtering sub, or undef
# @return float    number of miles in the filtered subset
sub how_far {
    my $set = shift->subset(shift);
    my $sum = 0; $sum += $_->[DIST] for @$set; $sum;
}

# @param JBD::Tempo::Data
# @param coderef [optional]    filtering sub, or undef
# @return int    number of runs in the filtered subset
sub how_many { scalar @{shift->subset(shift)} }

# @param JBD::Tempo::Data $this
# @param mixed $filter    a coderef, or undef
# @return arrayref    subset of run data, per $filter
sub subset {
    my ($this, $filter) = @_;
    my $data = $this->load;
    ref $filter eq 'CODE' ? [grep $filter->($_), @$data] : $data;
}


# @param JBD::Tempo::Data $this
# @param string    a Y-m-d
# @param float    number of miles
# @param string    running surface
# @param string    footwear worn
sub add_run {
    my $this = shift;
    my $data = $this->load;
    unshift @$data, [@_];
    $this->store->save($data);
}

# @param JBD::Tempo::Data $this
# @param arrayref $from    entries matching this
# @param arrayref $to    are replaced with this
sub replace_run {
    my ($this, $from, $to) = @_;
    my $data = $this->load;
    for (@$data) { $_ = $to if "@$_" eq "@$from" }
    $this->store->save($data);
}

# @param JBD::Tempo::Data $this
# @param string    a Y-m-d
# @param float    number of miles
# @param string    running surface
# @param string    footwear worn
sub remove_run {
    my $this = shift;
    my $data = $this->load;
    $this->store->save([grep "@$_" ne "@_", @$data]);
}


# @param JBD::Tempo::Data $this
# @return int    the year from the oldest entry
sub begin_year {
    my $this = shift;
    substr $this->load->[-1][DATE], 0, 4;
}

# @param JBD::Tempo::Data $this
# @return int    the year from the newest entry
sub end_year {
    my $this = shift;
    substr $this->load->[0][DATE], 0, 4;
}

# @param JBD::Tempo::Data $this
# @return arrayref    unique footwear in data set
sub footwear {
    my $this = shift;
    my %unique = map {$_->[FOOT] => 1} @{$this->load};
    [sort keys %unique];
}

# @param JBD::Tempo::Data $this
# @return arrayref    unique surfaces in data set
sub surfaces {
    my $this = shift;
    my %unique = map {$_->[SURF] => 1} @{$this->load};
    [sort keys %unique];
}

1;
