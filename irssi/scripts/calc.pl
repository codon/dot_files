use strict;
use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind active_win);
$VERSION = "1.00";
%IRSSI = (
    authors	=> "Juerd",
    contact	=> "juerd\@juerd.nl",
    name	=> "Calculator",
    description	=> "Simple /calc mechanism",
    license	=> "Public Domain",
    url		=> "http://juerd.nl/irssi/",
    changed	=> "Thu 28 Feb 16:04 CET 2002"
);

command_bind(
    calc => sub {
	my ($msg) = @_;
	for ($msg) {
	    s/,/./g;
	    s/[^*.+0-9&|)(x\/^-]//g;
	    s/\*\*/^/g;
	    s/([*+\\.\/x-])\1*/$1/g;
	    s/\^/**/g;
	    s/(?<!0)x//g;
	}
	my $answer = eval("($msg) || 0");
	active_win->print($@ ? "$msg = ERROR (${\ (split / at/, $@, 2)[0]})" : "$msg = $answer");
    }
);
