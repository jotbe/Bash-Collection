#!/bin/bash
#
# Creates an offline mirror of futurezone.orf.at articles
# Author: Jan Beilicke <dev@jotbe-fx.de>
# Created: 2010-06-23
# Last modified: 2010-06-24
#

BASEURL='http://futurezone.orf.at/stories'
INCLUDEDOMAINS='static.orf.at,futurezone.orf.at'
REJECT='[0-9]+/forum/.*'
EXCLUDEDOMAINS='login.orf.at,my.orf.at'
LOG='wget.log'

function getMaxId() {
  curl -s -S ${1%/*} | \
  egrep -o "$1/[0-9]+" | \
  egrep -o "[0-9]+$" | sort -r | uniq | head -n1
}

# This should be 0 after finishing the tests to fetch everything ;)
START=1651500
END=`getMaxId "$BASEURL"`

COUNT=0
REMAINING=0
WAIT=1
LEVELS=2
ROBOTS="off"
TRIES=5

echo "Searching and fetching articles. This will take a while."
#--exclude-domains "$EXCLUDEDOMAINS"
for i in `seq -f %f $START $END | cut -d, -f1`; do 
  wget -a "$LOG" \
    -e robots=$ROBOTS -k -nc -c -w$WAIT -x -E -rH -l$LEVELS \
    -D"$INCLUDEDOMAINS" --exclude-domains "$EXCLUDEDOMAINS" -R "$REJECT" \
    -p -np -t$TRIES $BASEURL/$i/
  [[ $? == 0 ]] && COUNT=$(($COUNT+1))
  REMAINING=$(($END-$i))
  echo -ne "\rFound and downloaded $COUNT articles ... $REMAINING to go ...";
done;

echo
echo "Finished."
echo
exit 0