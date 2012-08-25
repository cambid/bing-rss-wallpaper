#!/bin/bash
# Author: Jan Fader <jan.fader@web.de>
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or send
# a letter to Creative  Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

TEMPDIR=$(mktemp -d)
if [ -z $1 ]; then
  echo "please specify an url"
fi
URL=$1
wget -q $URL -O - | sed -e 's/$//' >>$TEMPDIR/theme
RSSURL=$(grep RSSFeed $TEMPDIR/theme | cut -f 2- -d '=')
wget -q $RSSURL -O - | sed -e 's/$//' >>$TEMPDIR/rss
WALLPAPERIMG=$(./xmlcat $TEMPDIR/rss | grep "enclosure url" | cut -f 2 -d '"' | shuf -n1)
wget -q "$WALLPAPERIMG" -O $TEMPDIR/img
feh --bg-scale $TEMPDIR/img
rm -r ${TEMPDIR}
