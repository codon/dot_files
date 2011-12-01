# Print the country name in /WHOIS replies
# /COUNTRY <code> prints the name for the country code
# for irssi 0.7.98 by Timo Sirainen
use strict;
use Irssi;
use vars qw($VERSION %IRSSI); 
$VERSION = "0.1";
%IRSSI = (
    authors	=> "Timo \'cras\' Sirainen",
    contact	=> "tss\@iki.fi",
    name	=> "country",
    description	=> "Print the country name in /WHOIS replies & /COUNTRY <code> prints the name for the country code",
    license	=> "Public Domain",
    url		=> "http://irssi.org",
    changed	=> "2002-03-04T22:47+0100"
);

my %countries;

Irssi::theme_register([
 whois => '{nick $0} {nickhost $1@$2} {comment $4}%: ircname  : $3'
# whois => '{nick $0} {nickhost $1@$2} {comment $4}%:{whois ircname $3}' # for irssi 0.7.99
]);

sub event_whois {
  my ($server, $data) = @_;
  my ($num, $nick, $user, $host, $empty, $realname) = split(/ +/, $_[1], 6);
  $realname =~ s/^://; 

  if ($host =~ /\.([a-zA-Z][a-zA-Z])$/) {
    my $country = $countries{uc($1)};
    if ($country) {
      $server->printformat($nick, MSGLEVEL_CRAP, 'whois',
    			   $nick, $user, $host, $realname, $country);
      Irssi::signal_stop();
    }
  }
}

sub cmd_country {
  my $country = uc shift;
  if ($country eq "") {
    Irssi::print("USAGE: /COUNTRY <country code>");
    return;
  }

  my $name = $countries{$country};
  if (!$name) {
    Irssi::print("Unknown country code: $country");
  } else {
    Irssi::print("$country is $name");
  }
}

Irssi::signal_add('event 311', 'event_whois');
Irssi::command_bind('country', 'cmd_country');

my $countryfile = '
# ISO 3166 2-letter country codes
#
# @(#)iso3166.tab	1.8
#
# From Paul Eggert <eggert@twinsun.com> (1999-10-13):
#
# This file contains a table with the following columns:
# 1.  ISO 3166-1:1999 2-character country code.  See:
#	<a href="http://www.din.de/gremien/nas/nabd/iso3166ma/codlstp1.html">
#	ISO 3166-1: The Code List
#	</a>.
# 2.  The usual English name for the country,
#	chosen so that alphabetic sorting of subsets produces helpful lists.
#	This is not the same as the English name in the ISO 3166 tables.
#
# Columns are separated by a single tab.
# The table is sorted by country code.
#
# Lines beginning with # are comments.
#
#country-
#code	country name
AD	Andorra
AE	United Arab Emirates
AF	Afghanistan
AG	Antigua & Barbuda
AI	Anguilla
AL	Albania
AM	Armenia
AN	Netherlands Antilles
AO	Angola
AQ	Antarctica
AR	Argentina
AS	Samoa (American)
AT	Austria
AU	Australia
AW	Aruba
AZ	Azerbaijan
BA	Bosnia & Herzegovina
BB	Barbados
BD	Bangladesh
BE	Belgium
BF	Burkina Faso
BG	Bulgaria
BH	Bahrain
BI	Burundi
BJ	Benin
BM	Bermuda
BN	Brunei
BO	Bolivia
BR	Brazil
BS	Bahamas
BT	Bhutan
BV	Bouvet Island
BW	Botswana
BY	Belarus
BZ	Belize
CA	Canada
CC	Cocos (Keeling) Islands
CD	Congo (Dem. Rep.)
CF	Central African Rep.
CG	Congo (Rep.)
CH	Switzerland
CI	Cote d\'Ivoire
CK	Cook Islands
CL	Chile
CM	Cameroon
CN	China
CO	Colombia
CR	Costa Rica
CU	Cuba
CV	Cape Verde
CX	Christmas Island
CY	Cyprus
CZ	Czech Republic
DE	Germany
DJ	Djibouti
DK	Denmark
DM	Dominica
DO	Dominican Republic
DZ	Algeria
EC	Ecuador
EE	Estonia
EG	Egypt
EH	Western Sahara
ER	Eritrea
ES	Spain
ET	Ethiopia
FI	Finland
FJ	Fiji
FK	Falkland Islands
FM	Micronesia
FO	Faeroe Islands
FR	France
GA	Gabon
GB	Britain (UK)
GD	Grenada
GE	Georgia
GF	French Guiana
GH	Ghana
GI	Gibraltar
GL	Greenland
GM	Gambia
GN	Guinea
GP	Guadeloupe
GQ	Equatorial Guinea
GR	Greece
GS	South Georgia & the South Sandwich Islands
GT	Guatemala
GU	Guam
GW	Guinea-Bissau
GY	Guyana
HK	Hong Kong
HM	Heard Island & McDonald Islands
HN	Honduras
HR	Croatia
HT	Haiti
HU	Hungary
ID	Indonesia
IE	Ireland
IL	Israel
IN	India
IO	British Indian Ocean Territory
IQ	Iraq
IR	Iran
IS	Iceland
IT	Italy
JM	Jamaica
JO	Jordan
JP	Japan
KE	Kenya
KG	Kyrgyzstan
KH	Cambodia
KI	Kiribati
KM	Comoros
KN	St Kitts & Nevis
KP	Korea (North)
KR	Korea (South)
KW	Kuwait
KY	Cayman Islands
KZ	Kazakhstan
LA	Laos
LB	Lebanon
LC	St Lucia
LI	Liechtenstein
LK	Sri Lanka
LR	Liberia
LS	Lesotho
LT	Lithuania
LU	Luxembourg
LV	Latvia
LY	Libya
MA	Morocco
MC	Monaco
MD	Moldova
MG	Madagascar
MH	Marshall Islands
MK	Macedonia
ML	Mali
MM	Myanmar (Burma)
MN	Mongolia
MO	Macao
MP	Northern Mariana Islands
MQ	Martinique
MR	Mauritania
MS	Montserrat
MT	Malta
MU	Mauritius
MV	Maldives
MW	Malawi
MX	Mexico
MY	Malaysia
MZ	Mozambique
NA	Namibia
NC	New Caledonia
NE	Niger
NF	Norfolk Island
NG	Nigeria
NI	Nicaragua
NL	Netherlands
NO	Norway
NP	Nepal
NR	Nauru
NU	Niue
NZ	New Zealand
OM	Oman
PA	Panama
PE	Peru
PF	French Polynesia
PG	Papua New Guinea
PH	Philippines
PK	Pakistan
PL	Poland
PM	St Pierre & Miquelon
PN	Pitcairn
PR	Puerto Rico
PS	Palestine
PT	Portugal
PW	Palau
PY	Paraguay
QA	Qatar
RE	Reunion
RO	Romania
RU	Russia
RW	Rwanda
SA	Saudi Arabia
SB	Solomon Islands
SC	Seychelles
SD	Sudan
SE	Sweden
SG	Singapore
SH	St Helena
SI	Slovenia
SJ	Svalbard & Jan Mayen
SK	Slovakia
SL	Sierra Leone
SM	San Marino
SN	Senegal
SO	Somalia
SR	Suriname
ST	Sao Tome & Principe
SV	El Salvador
SY	Syria
SZ	Swaziland
TC	Turks & Caicos Is
TD	Chad
TF	French Southern & Antarctic Lands
TG	Togo
TH	Thailand
TJ	Tajikistan
TK	Tokelau
TM	Turkmenistan
TN	Tunisia
TO	Tonga
TP	East Timor
TR	Turkey
TT	Trinidad & Tobago
TV	Tuvalu
TW	Taiwan
TZ	Tanzania
UA	Ukraine
UG	Uganda
UM	US minor outlying islands
US	United States
UY	Uruguay
UZ	Uzbekistan
VA	Vatican City
VC	St Vincent
VE	Venezuela
VG	Virgin Islands (UK)
VI	Virgin Islands (US)
VN	Vietnam
VU	Vanuatu
WF	Wallis & Futuna
WS	Samoa (Western)
YE	Yemen
YT	Mayotte
YU	Yugoslavia
ZA	South Africa
ZM	Zambia
ZW	Zimbabwe
';

foreach my $line (split(/\n/, $countryfile)) {
  chomp $line;
  next if ($line =~ /^#/ || $line eq ""); 

  my ($code, $name) = split(/\t/, $line);
  $countries{$code} = $name;
}
