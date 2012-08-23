# Copyright 2012 - Jan Fader <jan.fader@web.de>
# Todos: errorhandling, Konfigurierbarkeit, usw...
# 
#SAVEPWD=$(pwd)
TEMPDIR=$(mktemp -d)
#cd $TEMPDIR
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

#cleanup
rm -r ${TEMPDIR}
