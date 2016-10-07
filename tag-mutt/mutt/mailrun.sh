#!/bin/sh

export LANG=C

LOGFILE=${HOME}/offlineimap.log

echo `date` "Starting" >> ${LOGFILE}
/usr/bin/flock --exclusive --timeout 5 /tmp/offlineimap.lock -c /usr/bin/offlineimap 2>&1 >> ${LOGFILE} || echo `date` "Locked" >> ${LOGFILE}
echo `date` "Done" >> ${LOGFILE}
echo >> ${LOGFILE}
