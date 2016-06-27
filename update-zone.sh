#!/usr/local/bin/bash
# All code by John Newman jnn@synfin.org 2016
#
# do what you want with it :P
# may require slight mod on non-freebsd, does require gsed on freebsd

namedb_dir="/etc/namedb/master"

if [ -n "$1" ] ; then
    zone=$1
else
    zone="synfin.org"
fi

if [ ! -d "$namedb_dir" ] ; then 
    echo "Fatal - '$namedb_dir' doesnt exist!"
    exit 1
elif [ ! -f "$namedb_dir/$zone" ] ; then
    echo "Fatal - zone file '$zone' doesnt exist!"
    exit 1
fi

cd $namedb_dir
svn status > /tmp/svn.dns.$$
if [ ! -s /tmp/svn.dns.$$ ] ; then
    echo "You have existing changes that need to be checked in - "
    cat /tmp/svn.dns.$$
    rm -f /tmp/svn.dns.$$
    exit 1
fi

soa="${zone}.[[:space:]]*1800[[:space:]]*IN[[:space:]]*SOA[[:space:]]*ns1.${zone}.[[:space:]]*hostmaster.${zone}."

sn=$(head -1 $zone | awk '/SOA/ { print $7 }')
sn2="$(date '+%Y%m%d')00"

# multiple edits on the same day (or a fucked sn)
if [ "$sn2" -le "$sn" ] ; then
    sn2=$(( sn + 1 ))
fi
/usr/local/bin/gsed -i "s/^\(${soa}[[:space:]]*\)${sn}/\1${sn2}/"  "$zone"
vim "$zone"
svn commit "$zone"
rndc reload "$zone"
rm -f /tmp/svn.dns.$$
