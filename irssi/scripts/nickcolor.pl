# assign a different color for each nick
# for irssi 0.7.98 by Timo Sirainen

use Irssi;
use strict;

my $saved_colors = {
  'ElectricElf' => 4
};

my @use_colors = (
  2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13

);

# is there already a hash function in perl? is there easier way to
# go through the string? this must be slow :)
sub str_hash {
  my $str = $_[0];
  my $value = 0;

  my $len = length($str);
  for (my $n = 0; $n < $len; $n++) {
    $value = ($value << 5) - $value + ord(substr($str, $n, 1));
  }
  return $value;
}

sub sig_public {
  my ($server, $msg, $nick, $address, $target) = @_;
  my $formatstuff = "";

  my $color = $saved_colors->{$nick};
  $color = $use_colors[str_hash($nick) % scalar(@use_colors)] if (!$color);
  $color = "0".$color if ($color < 10);

  $formatstuff = '/^format pubmsg {pubmsgnick $2 {pubnick '.chr(3).$color.'$[-13]0 %n| }}$1';
  $server->command($formatstuff);

  $formatstuff = '/^format pubmsg_channel {pubmsgnick $3 {pubnick '.chr(3).$color.'$[-13]0} %n| %m({msgchannel $1})%n}$2';
  $server->command($formatstuff);
}

sub sig_action {
  my ($server, $msg, $nick, $address, $target) = @_;
  my $formatstuff = "";

  my $color = $saved_colors->{$nick};
  $color = $use_colors[str_hash($nick) % scalar(@use_colors)] if (!$color);
  $color = "0".$color if ($color < 10);

  $formatstuff = '/^format action_public {pubaction '.chr(3).$color.'$[-12]0%n}$1';
  $server->command($formatstuff);

  $formatstuff = '/^format action_public_channel {pubaction '.chr(3).$color.'$[-11]0  %m({msgchannel $1})%n}$2';
  $server->command($formatstuff);
}

Irssi::signal_add('message public', 'sig_public');
Irssi::signal_add('message irc action', 'sig_action');
