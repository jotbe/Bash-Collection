#!/bin/bash -e  
#
# Checks for available Subversion updates
#
# - Notifications are optionally send via Growl (growlnotify)
# 
# Take care to edit the variables as neccessary!
#
# Author: Jan Beilicke <dev@jotbe-fx.de>
# Created: 2010-06-10
# Last modified: 2010-06-24
#
# -------------------------------------------------------------------
#
# Usage: svn-check-rev.sh [-h] [-n] [-s] /path/to/svn/working/copy/
# Parameters:
# -h          Display help
# -n          Use Growl to notify about updates (requires 'growlnotify' in \$PATH)
# -s          Sticky growl notification (automatically enables Growl)
#

### General ###
PATH="/usr/bin:/opt/local/bin:/usr/local/bin:${PATH}"
NOTIFIER=`which growlnotify`
SVN=`which svn`

##### Do not edit anything below this line! #####
USEGROWL=false
STICKY=false

E_BADARGS=65

usage() {
  cat <<EOF

Usage: `basename $0` [-h] [-n] [-s] /path/to/svn/working/copy/
Parameters:
-h          Display this help
-n          Use Growl to notify about updates (requires 'growlnotify' in \$PATH)
-s          Sticky growl notification (automatically enables Growl)

EOF
}

while getopts "hnsd:" ARG; do
  case "${ARG}" in
    h )
      usage
      exit 1
    ;;
    n )
      if [[ ! -e "$NOTIFIER" ]]; then
        echo "Growl not found. Continuing without it ..."
        USEGROWL=false
      else
        USEGROWL=true
      fi
    ;;
    s )
      if [[ ! -e "$NOTIFIER" ]]; then
        echo "Growl not found. Continuing without it ..."
        USEGROWL=false
        STICKY=false
      else
        USEGROWL=true
        STICKY=true
      fi
    ;;
    ? ) 
      usage
      exit 1
    ;;
    * )
      echo
      echo "Unkown error while processing parameters."
      exit 1
  esac
done

if [[ ! -d "${!#}" ]]; then
  echo
  echo "Last argument isn't a directory or doesn't exist."
  usage
  exit 1
fi

SVNWCPATH="${!#}"

[[ "$STICKY" = true ]] && SETSTICKY="-s"

SVNURL=`$SVN info $SVNWCPATH | awk '/URL:/ {print $2}'`
LOCALREV=`$SVN info $SVNWCPATH | awk '/Revision:/ {print $2}'`
REMOTEREV=`$SVN info -rHEAD $SVNWCPATH | awk '/Revision:/ {print $2}'`

echo
echo "URL: $SVNURL"
echo "Local revision: $LOCALREV"
echo "Remote revision: $REMOTEREV"

DIFFREV=$((REMOTEREV - LOCALREV))

if [[ "$DIFFREV" -gt 0 ]]; then
  if [[ "$USEGROWL" = true ]] && [[ -e "$NOTIFIER" ]]; then
    "$NOTIFIER" "$SETSTICKY" -d "$SVNURL" -m "${SVNURL##*/}: Updates available! Remote rev. is $REMOTEREV (local rev. $LOCALREV)"
  fi
  echo
  echo "Updates available!"
else
  echo
  echo "No updates available."
fi

echo
exit 0
