
# Encloses an array of lexed JBD::Parser::Tokens, embodies
# the state of a parse in progress, & provides related subs.
# @author Joel Dalley
# @version 2014/Mar/11

package JBD::Parser::State;

use JBD::Core::stern;
use JBD::Core::Exporter ':omni';

configure_object: {
    no strict 'refs';
    my %h = (lexed_tokens => 0, 
             lexed_count  => 1,
             parsed_count => 2, 
             parse_frame  => 3);
    while (my ($s, $i) = each %h) {
        *$s = sub :lvalue {$_[0]->[$i]};
    }
}

# @param arrayref Array of JBD::Parser::Tokens.
# @return JBD::Parser::State
sub parser_state($) { __PACKAGE__->new(shift) }

# @param string $type Object type.
# @param arrayref $lexed_tokens Array of JBD::Parser::Tokens.
# @return JBD::Parser::State
sub new {
    my ($type, $lexed_tokens) = @_;
    my $this = bless [$lexed_tokens, 0, 0, {}], $type;
    $this->lexed_count = @{$this->lexed_tokens};
    $this;
}

# @param JBD::Parser::State $this
# @return JBD::Parser::Token The token at the cursor position.
sub current_lexed_token {
    my $this = shift;
    $this->lexed_tokens->[$this->parse_frame_cursor];
}

# @param JBD::Parser::State
# @return hashref Empty and return the empty parse frame.
sub begin_parse_frame { shift->parse_frame = {} }

# @param JBD::Parser::State $this
# @param string $type A JBD::Parser::Token type.
# @param mixed [opt] $val Optional token value.
sub parse_frame_pair_args {
    my ($this, $type, $val) = @_;
    $this->parse_frame->{pair_args} = []
        if !exists $this->parse_frame->{pair_args};
    push @{$this->parse_frame->{pair_args}},
         qq|"$type: | . (defined $val ? $val : 'UNDEF') . '"';
}

# @param JBD::Parser::State $this
# @param mixed $pos A number, the plus sign '+', or undef.
# @return int The cursor position, for the lexed tokens array.
sub parse_frame_cursor {
    my ($this, $pos) = @_;
    my $C = $this->parse_frame->{cursor} || $this->parsed_count;
    $C = defined $pos ? $pos eq '+' ? $C + 1 : $pos : $C;
    $this->parse_frame->{cursor} = $C;
}

# @param JBD::Parser::State $this
# @return The number of lexed tokens that are now parsed.
sub parse_frame_success {
    my $this = shift;
    $this->parsed_count = $this->parse_frame_cursor('+');
}

# @param JBD::Parser::State $this
# @param string [opt] $msg An error message, or undef.
sub parse_frame_error {
    my ($this, $msg) = @_;
    $this->parse_frame->{error} = $msg if defined $msg;
}

# @param JBD::Parser::State $this
# @return string A basic description of the parse error.
sub error_string {
    my $this = shift;
    my $pf = $this->parse_frame;
    my $e = $pf->{error} || 'ERROR MISSING';
    my $m = join ', ', @{$pf->{pair_args}};
    my $l = $this->current_lexed_token;
    my $lexed = $this->lexed_tokens;
    my $cnt = $this->parsed_count;
    my $near = '... ' . join ' ', 
               map {$_->value ? $_->value : $_->type}
               grep $_, @$lexed[$cnt .. $cnt + 2];

    return "Parsed $cnt tokens before error near "
         . "`$near`.\nCould not parse token `$l` with"
         . qq| the type, value pair $m.\n$e\n\n|;
}

# @param JBD::Parser::State $this
# @return int 1 if done parsing, or else 0.
sub done_parsing {
    my $this = shift;
    $this->parsed_count >= $this->lexed_count || 
    $this->parse_frame_cursor > $this->lexed_count
    ? 1 : 0;
}

1;
