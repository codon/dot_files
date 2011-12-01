use Irssi;
use Irssi::Irc;

sub sig_mynotice {
    return if $already_processed;

    $already_processed = 1;

    my ($server, $msg, $nick, $address, $target) = @_;

    $msg =~ s/\.oftc\.net//ig;
    $msg =~ s/\.openprojects\.net//ig;
    $msg =~ s/Notice -- //ig;

    $nick =~ s/\.openprojects\.net//ig;

    $colour_format = '%w'; ## Default for non-hilighted messages
    ## Server connection stuff - START
    if ( $msg =~ /CHALL received/ ) { $colour_format = '%B'; };
    if ( $msg =~ /Got a good password response from/ ) { $colour_format = '%B'; };
    if ( $msg =~ /Link with .* established:/ ) { $colour_format = '%B'; };
    ## Server connection stuff - END
    ## General server maintenance - START
    if ( $msg =~ /rehashing/ ) { $colour_format = '%B'; };
    if ( $msg =~ /Got signal SIGHUP, reloading ircd conf/ ) { $colour_format = '%B'; };
    if ( $msg =~ /rehosting/ ) { $colour_format = '%B'; };
    if ( $msg =~ /activated an O:line/ ) { $colour_format = '%Y'; };
    ## General server maintenance - END
    ## Kills, and attempts to do stuff which failed - START
    if ( $msg =~ /K:line/ ) { $colour_format = '%W'; };
    if ( $msg =~ /KILL/ ) { $colour_format = '%W'; };
    if ( $msg =~ /Failed OPER attempt/ ) { $colour_format = '%B'; };
    if ( $msg =~ /jupe/ ) { $colour_format = '%R'; };
    ## Kills, and attempts to do stuff which failed - END
    if ( $msg =~ /spambot/ ) { $colour_format = '%m'; };
    if ( $msg =~ /Flooder/ ) { $colour_format = '%M'; };
    if ( $msg =~ /Kick/ ) { $colour_format = '%M'; };
    if ( $msg =~ /requested by/ ) { $colour_format = '%c'; };
    if ( $msg =~ /Client connecting/ ) { $colour_format = '%b'; };
    if ( $msg =~ /Client exiting/ ) { $colour_format = '%b'; };
    if ( $msg =~ /.*[Cc]hannel.*created.by.*/ ) { $colour_format = '%y'; };

    $server->command('/^format notice_server '.$colour_format.'{servernotice $[-10]0}$1');

    Irssi::signal_emit("message irc notice", $server, $msg,
               $nick, $address, $target);
    Irssi::signal_stop();
    $already_processed = 0;
}                 

Irssi::signal_add('message irc notice', 'sig_mynotice');

