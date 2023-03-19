package App::Greple::xlate::deepl;

our $VERSION = "0.18";

use v5.14;
use warnings;
use Encode;
use Data::Dumper;

use List::Util qw(sum);
use App::cdif::Command;

our $lang_from //= 'ORIGINAL';
our $lang_to   //= 'JA';
our $auth_key;
our $method = 'deepl';

my %param = (
    deepl     => { max => 128 * 1024, sub => \&deepl },
    clipboard => { max => 5000,       sub => \&clipboard },
    );

sub deepl {
    state $deepl = App::cdif::Command->new;
    state $command = [ 'deepl', 'text',
		       '--to' => $lang_to,
		       $auth_key ? ('--auth-key' => $auth_key) : () ];
    $deepl->command([@$command, +shift])->update->data;
}

sub clipboard {
    use Clipboard;
    my $from = shift;
    my $length = length $from;
    Clipboard->copy($from);
    STDERR->printflush(
	"$length characters stored in the clipboard.\n",
	"Translate it to \"$lang_to\" and clip again.\n",
	"Then hit enter: ");
    if (open my $fh, "/dev/tty" or die) {
	my $answer = <$fh>;
    }
    my $to = Clipboard->paste;
    $to = decode('utf8', $to) if not utf8::is_utf8($_);
    return $to;
}

sub xlate_each {
    my $call = $param{$method}->{sub} // die;
    my @count = map { int tr/\n/\n/ } @_;
    my $to = $call->(join '', @_);
    my @out = $to =~ /.*\n/g;
    if (@out < sum @count) {
	die "Unexpected response from deepl command:\n\n$to\n";
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

option default -Mxlate --xlate-engine=deepl
