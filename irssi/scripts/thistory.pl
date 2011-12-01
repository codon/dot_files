# thistory.pl v1.01
# Copyright (C) 2001  Teemu Hjelt <temex@iki.fi>
#
# Written for irssi 0.7.98, idea from JSuvanto
# Many thanks to fuchs for his help and suggestions.
#
# Holds the information about the ten recent topics.  
# Usage: /thistory [channel] and /tinfo [channel]

use Irssi;
use Irssi::Irc;

sub cmd_topicinfo {
	my ($channel) = @_;
	$channel =~ s/\s*$//;
	my $ircnet = Irssi::active_server()->{'tag'};

	if ($channel eq "") {
		if (Irssi::channel_find(Irssi::active_win()->get_active_name())) {
			$channel = Irssi::active_win()->get_active_name();
		}
	}
	if ($channel ne "") {
		if ($topiclist{lc($ircnet)}{lc($channel)}{0}) {
			Irssi::print("%W$channel%n: " . $topiclist{lc($ircnet)}{lc($channel)}{0}, MSGLEVEL_CRAP);
		} else {
			Irssi::print("No topic information for %W$channel%n", MSGLEVEL_CRAP);
		}
	} else {
		Irssi::print("Usage: /tinfo <channel>");
	}
}

sub cmd_topichistory {
	my ($channel) = @_;
	$channel =~ s/\s*$//;
	my $ircnet = Irssi::active_server()->{'tag'};

        if ($channel eq "") {
                if (Irssi::channel_find(Irssi::active_win()->get_active_name())) {
                        $channel = Irssi::active_win()->get_active_name();
                }
        }
	if ($channel ne "") {
		if ($topiclist{lc($ircnet)}{lc($channel)}{0}) {
			Irssi::print("Topic history for %W$channel%n:", MSGLEVEL_CRAP);
			for (my $i = 0; $i <= 9; $i++) {
				if ($topiclist{lc($ircnet)}{lc($channel)}{$i}) {
					Irssi::print(($i + 1) . ". " . $topiclist{lc($ircnet)}{lc($channel)}{$i}, MSGLEVEL_CRAP);
				}
			}
		} else {
			Irssi::print("No topic history for %W$channel%n", MSGLEVEL_CRAP);
		}
	} else {
		Irssi::print("Usage: /thistory <channel>");
	}
}

sub event_topic {
	my ($server, $data, $nick, $address) = @_;
	my ($channel, $topic) = split(/ :/, $data, 2);
	my $ircnet = Irssi::active_server()->{'tag'};
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

	$year = $year + 1900;
	if ($sec < 10) { $sec = "0$sec" }
	if ($min < 10) { $min = "0$min" }
	if ($hour < 10) { $hour = "0$hour" }
        for (my $i = 9; $i >= 0; $i--) {
		$topiclist{lc($ircnet)}{lc($channel)}{$i+1} = $topiclist{lc($ircnet)}{lc($channel)}{$i};
        }
        $topiclist{lc($ircnet)}{lc($channel)}{0} = "\"$topic\" - $nick [$mday.$mon.$year $hour:$min:$sec]";
}

Irssi::command_bind("topichistory", "cmd_topichistory");
Irssi::command_bind("thistory", "cmd_topichistory");
Irssi::command_bind("topicinfo", "cmd_topicinfo");
Irssi::command_bind("tinfo", "cmd_topicinfo");
Irssi::signal_add("event topic", "event_topic");

