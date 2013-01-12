#!/bin/bash
# Author: Jan Fader <jan.fader@web.de>
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or send
# a letter to Creative  Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

# configuration part
NEEDEDPROGRAMS="feh wget"
WGETNUMBEROFRETRIES=3
WGETCOUNTER=0
WGETMAXCOUNTER=3
TEMPDIR=$(mktemp -d)
URL=$1

# don't modify below!

for program in $NEEDEDPROGRAMS; do
  if [ $(type $program >/dev/null 2>&1; echo $?) -ne 0 -o ! -x $(type -P $program)  ]; then
    echo "$program is needed for this and have to be executeable"
    exit 4
  fi
done

if [ -z $1 ]; then
  echo "please specify an url"
  exit 2
fi

# gets $1 to $2 (use - for stdout)
function downloadFile()
{
  wget -t $WGETNUMBEROFRETRIES -q "$1" -O "$2"
}

function downloadErrorExit()
{
  echo "could not download $1 file"
  exit 3
}

function checkWGETCounter()
{
  if [ $WGETCOUNTER -ge $WGETMAXCOUNTER ]; then
    downloadErrorExit "$1"
  fi
}

while ( [ ! -s $TEMPDIR/theme ] ); do
  downloadFile "$URL" - | recode ibmpc..lat1 >>$TEMPDIR/theme
  let WGETCOUNTER++
  checkWGETCounter "theme"
done
WGETCOUNTER=0

RSSURL=$(grep RSSFeed $TEMPDIR/theme | cut -f 2- -d '=')

while ( [ ! -s $TEMPDIR/rss ] ); do
  downloadFile "$RSSURL" - | recode ibmpc..lat1 >>$TEMPDIR/rss
  let WGETCOUNTER++
  checkWGETCounter "rss"
done
WGETCOUNTER=0

WALLPAPERIMG=$(sed -e 's/\(<[^<>]\)/\n\1/g' $TEMPDIR/rss | grep "enclosure url" | cut -f 2 -d '"' | shuf -n1)
while ( [ ! -s $TEMPDIR/img ] ); do
  downloadFile "$WALLPAPERIMG" $TEMPDIR/img
  let WGETCOUNTER++
  checkWGETCounter "img"
done

# finally sets the image via feh and cleanup the tempdir
feh --bg-scale $TEMPDIR/img
rm -r ${TEMPDIR}
exit 0
