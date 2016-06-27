#!/bin/bash

CONF="${HOME}/.bash_conf"
LAST_RAN="${HOME}/var/ipecho.last_ran"
IPECHO_IP="${HOME}/var/ipecho.txt"

test -f "${CONF}" || { echo "Error - bash conf (${CONF}) not found" ; exit 1; }
source "${CONF}"

declare -i t
declare -i t2

t=$(date '+%s')
timeout=$(get_conf ipecho timeout)
last_ran=0

if [ -f "${LAST_RAN}" ] ; then
    last_ran=$(cat "${LAST_RAN}")
fi

t2=$((t - timeout))

if [ ${t2} -gt ${last_ran} ] ; then
    curl ipecho.net/plain 2> /dev/null | tee "${IPECHO_IP}" 
    echo "${t}" > "${LAST_RAN}"
else 
    cat "$IPECHO_IP"
fi

