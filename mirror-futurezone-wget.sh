#!/bin/bash

BASEURL='http://futurezone.orf.at/stories'
INCLUDEDOMAINS='static.orf.at,futurezone.orf.at'
REJECT='*login.orf.at/*'
EXCLUDEDOMAINS='login.orf.at'
LOG='wget.log'

function getMaxId() {
  curl -s -S ${1%/*} | \
  egrep -o "$1/[0-9]+" | \
  egrep -o "[0-9]+$" | sort -r | uniq | head -n1
}

START=1651300
END=`getMaxId "$BASEURL"`

COUNT=0
REMAINING=0
WAIT=1
LEVELS=2
ROBOTS="off"
TRIES=5

echo "Searching and fetching articles. This will take a while."

for i in `seq -f %f $START $END | cut -d, -f1`; do 
  wget -a "$LOG" \
    -e robots=$ROBOTS -k -nc -c -w$WAIT -x -E -r -l$LEVELS \
    -D "$INCLUDEDOMAINS" -R "$REJECT" --exclude-domains "$EXCLUDEDOMAINS" \
    -p -np -H -t$TRIES $BASEURL/$i/
  [[ $? == 0 ]] && COUNT=$(($COUNT+1))
  REMAINING=$(($END-$i))
  echo -ne "\rFound and downloaded $COUNT articles ... $REMAINING to go ...";
done;

echo
echo "Finished."
echo
exit 0