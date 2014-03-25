package JBD::Core::String;
# ABSTRACT: string functions
# VERSION

# String functions.
# @author Joel Dalley
# @version 2014/Feb/23

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';

sub simplify($) {
    my $str = shift;
    return '' unless _is($str);
    $str =~ s/[\W_]+//og;
    $str ? lc $str : '';
}

sub ascii($) {
    my $str = shift;
    return 0 unless _is($str);
    bool($str !~ /[^[:ascii:]]/o);
}

sub contains($$) {
    my ($a, $b) = @_;
    return 0 unless _is($a) && _is($b);
    index($a, $b) >= 0;
}

sub has_ellipsis($) {
    my $str = shift;
    return 0 unless _is($str);
    return 1 if index($str, '...') >= 0;
    return 1 if $str =~ m{\x{2026}}o;
    0;
}

sub hashlike($) {
    my $str = shift;
    return 0 unless _is($str);
    return 1 if $str =~ /^[a-fA-F0-9]{32,40}$/o;
    0;
}

sub add_commas($) {
    my $num = shift;
    return $num unless _is($num) && $num =~ /^\d+$/o;
    $num =~ s/(^[-+]?\d+?(?=(?>(?:\d{3})+)(?!\d))|\G\d{3}(?=\d))/$1,/g;
    $num;
}

sub abbr($$) {
    my ($str, $len) = @_;
    return unless _is($str) && $len;
    length $str gt $len ? substr($str, 0, $len-3) . '...' : $str;
}

sub trim($) {
    my $str = shift;
    $str =~ s/^\s*//g;
    $str =~ s/\s*$//g;
    $str =~ s/[\n\r]$//g;
    $str;
}

sub _is($) {
    my $maybe = shift;
    defined $maybe && length $maybe;
}

1;
