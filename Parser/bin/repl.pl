
# Lexer / Parser REPL.
# Allows quick exploration of parsers on input texts.
# @author Joel Dalley
# @version 2014/Mar/09

use JBD::Parser::Lexer::Std 'std_symbols';
use JBD::Parser::DSL;

my @hist;
my @stack;
my $parser;
my $lextypes;

while (1) {
    if    (!$lextypes) { print " : > Lex for types: \n : > " }
    elsif (!$parser)   { print " : > Enter a parser:\n : > " }
    else               { print " : > "                       }

    chomp(my $in = <STDIN>);
    last if $in =~ /^q(uit)?;$/io;

    if ($in =~ /^END;?$/) {
        print " : >\n";
        while (defined(my $text = shift @stack)) {
            print " : > Parse $text\n";
            my $stream = input $text, $lextypes;
            my ($tok) = $parser->($stream);
            print ref $tok && @$tok
                ? join("\n", map(" : > \tToken[$_]", @$tok)) . 
                  "\n : > \n"
                : (ref $tok ? 'No matches' : 'Undefined') .
                  "\n : > \n";
        }
        $parser = undef;
    }
    elsif ($in =~ /^h(ist(ory)?)?\s*(\d+)?;?$/) {
        my $hist_in = $3;

        if (!defined $hist_in) {
            for (my $i = 0; $i < @hist; $i++) {
                print " History: > [$i] $hist[$i]\n";
            }
            print " Enter a number: > ";
            chomp($hist_in = <STDIN>);
        }

        if (defined $hist_in && 
            $hist_in eq int($hist_in) &&
            $hist[$hist_in]) {
            my $ans = eval $hist[$hist_in];
            $parser = $ans if !$@;
        }
    }
    elsif (!$lextypes) {
        my $val = eval "[$in]";
        next if $@ || !@$val;
        my $have_all = 1;
        M: for my $m (@$val) {
            next M if grep ref $m eq ref $_, std_symbols;
            $have_all = 0;
            last M;
        }
        $lextypes = $val if !$@ && $have_all;
    }
    elsif (!$parser) {
        my $ans = eval $in;
        next if $@ || ref $ans ne 'JBD::Parser';
        $parser = $ans;
        print " : > Enter one or more strings to parse.\n",
              " : > Enter 'END' to parse strings.\n";
        push @hist, $in;
    }
    else {
        push @stack, $in;
    }
}
