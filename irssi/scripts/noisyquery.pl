# prints "Query started with nick in window x" when query windows are
# created automatically. For irssi 0.7.98

use Irssi;

sub sig_query() {
	my ($query, $auto) = @_;

	# don't say anything if we did /query,
	# or if query went to active window
        my $refnum = $query->window()->{refnum};
	my $window = Irssi::active_win();
	if ($auto && $refnum != $window->{refnum}) {
		$window->print("Query started with ".$query->{name}.
			       " in window $refnum");
	}
}

Irssi::signal_add_last('query created', 'sig_query');

