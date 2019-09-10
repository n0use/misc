#!/bin/sh
# dnssec-update.sh - 
#  John Newman jnn@synfin.org @ Wed Mar  6 11:07:17 EST 2019
#  - first version, a super simple dnssec updater for synfin.org zone
#
#  John Newman jnn@synfin.org @ Tue Aug  6 10:14:21 EDT 2019
#  - fixes, updates so it logs by default to /var/log/dnssec-sign.log
#  - takes one argument, -v, which will make it ALSO log to terminal
#  - this code is super simple, designed to work on one zone but it can
#  - take two optional arguments [zone [zonefile]], right now ZONEDIR still
#  - has to be set inside the script
#
#  - at some time in future i may generalize it a bit into a proper script :)


# save current working dir, in case this is run from CLI
PDIR=$(pwd)

# location of zone files
ZONEDIR="/usr/local/etc/namedb/master" 
ZONE="synfin.org"
ZONEFILE="synfin.org"
DNSSERVICE="named" 

log_file="/var/log/dnssec-update.log"
version="1.0b"
verbose=0

log()
{
    msg=$*
    log_str=$(echo -n $(date "+%b %d %T $(hostname -s)") $0[$$]: $msg) 
    if [ "$verbose" = "1" ] ; then
        echo $log_str | tee -a $log_file
    else
        echo $log_str >> $log_file
    fi
}

if [ "$1" = "-v" ]  ; then
    verbose=1
    shift
fi

# optionally pass a zone and zonefile in as the first and second arguments, after optional -v

if [ -n "$1" ] ; then
    ZONE="$1"
    if [ -n "$2" ] ; then
        ZONEFILE="$2"
    fi
fi

log "dnssec-update.sh version $version starting, configured for zone $ZONE, zone file at ${ZONEDIR}/${ZONEFILE}"

cd $ZONEDIR

serial=$(/usr/local/sbin/named-checkzone $ZONE $ZONEFILE | egrep -ho '[0-9]{10}')
log "zone $ZONE: old serial is '$serial'"

new_serial=$(date +'%Y%m%d01')

if [ "$new_serial" -le "$serial" ] ; then
    new_serial=$(( serial + 1 ))
fi

log "zone $ZONE: updating serial to '$new_serial'"

sed -i".dnssec-update-bak-$serial" 's/'$serial'/'$new_serial'/' $ZONEFILE

log "signing $ZONE"
/usr/local/sbin/dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1 | cut -b 1-16) -N increment -o $ZONE -t $ZONEFILE

log "reloading named"
# /usr/local/etc/rc.d/named reload
service named reload
rc=$?

log "service named reload exit value [$?]"
log "dnssec-update.sh exiting"

cd $PDIR
