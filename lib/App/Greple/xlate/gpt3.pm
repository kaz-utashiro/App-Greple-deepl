package App::Greple::xlate::gpt3;

our $VERSION = "0.26";

use v5.14;
use warnings;
use Encode;
use Data::Dumper;

use List::Util qw(sum);
use App::cdif::Command;

use App::Greple::xlate qw(opt);
use App::Greple::xlate::Lang qw(%LANGNAME);

our $lang_from //= 'ORIGINAL';
our $lang_to   //= 'JA';
our $auth_key;
our $method = 'gpt3';

my %param = (
    gpt3 => { engine => 'gpt-3.5-turbo', temp => '0', max => 1000, sub => \&gpty },
);

sub gpty {
    state $gpty = App::cdif::Command->new;
    my $param = $param{$method};
    my $prompt = sprintf("Translate following text into %s, line-by-line.",
			 $LANGNAME{$lang_to} // die "$lang_to: unknown lang.\n");
    my @command = (
	'gpty',
	-e => $param->{engine},
	-t => $param->{temp},
	$prompt, '-',
    );
    $gpty->command(\@command)->setstdin(+shift)->update->data;
}

sub _progress {
    print STDERR @_ if opt('progress');
}

sub xlate_each {
    my $call = $param{$method}->{sub} // die;
    my @count = map { int tr/\n/\n/ } @_;
    _progress("From:\n", map s/^/\t< /mgr, @_);
    my $to = $call->(join '', @_);
    my @out = $to =~ /^.+\n/mg;
    _progress("To:\n", map s/^/\t> /mgr, @out);
    if (@out < sum @count) {
	die "Unexpected response:\n\n$to\n";
    }
    map { join '', splice @out, 0, $_ } @count;
}

sub xlate {
    my @from = map { /\n\z/ ? $_ : "$_\n" } @_;
    my @to;
    my $max = $App::Greple::xlate::max_length || $param{$method}->{max} // die;
    while (@from) {
	my @tmp;
	my $len = 0;
	while (@from) {
	    my $next = length $from[0];
	    last if $len + $next > $max;
	    $len += $next;
	    push @tmp, shift @from;
	}
	push @to, xlate_each @tmp;
    }
    @to;
}

1;

__DATA__

option default -Mxlate --xlate-engine=gpt3
