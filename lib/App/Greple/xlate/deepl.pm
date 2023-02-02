package App::Greple::xlate::deepl;

our $VERSION = "0.03";

use v5.14;
use warnings;
use Data::Dumper;

use App::cdif::Command;

our $lang_from //= 'ORIGINAL';
our $lang_to   //= 'JA';
our $auth_key;
our $max_length = 128 * 1024;

sub xlate {
    state $deepl = App::cdif::Command->new;
    state $command = [ 'deepl', 'text',
		       '--to' => $lang_to,
		       $auth_key ? ('--auth-key' => $auth_key) : () ];
    my @from = map { /\n\z/ ? $_ : "$_\n" } @_;
    my $from = join '', @from;
    my @count = map { int tr/\n/\n/ } @from;
    my $to = $deepl->command([@$command, $from])->update->data;
    my @out = $to =~ /.*\n/g;
    map { join '', splice @out, 0, $_ } @count;
}

1;

__DATA__

option default -Mxlate --xlate-engine=deepl
