#!/usr/bin/env /bin/sh


do_rotate()
{
    base_name=$1
    num_backups=$2

    i=$num_backups

    # not using for 'for ((..))' or 'for i in {...}' syntax, its bash-only
    while [ "$i" -gt 0 ] ; do
        j=$((i - 1))
        src_name="${base_name}.${j}"
        dest_name="${base_name}.${i}"
        test -e "$src_name" && mv "$src_name" "$dest_name"
        i="$j"
    done

    test -e "${base_name}" && mv "${base_name}" "${base_name}.0"
}

fatal()
{
    msg=$1
    echo "$msg"
    exit 1
}

base_name=$1
max_backups=$3

if [ -z "$base_name" ] ; then
    fatal "Usage: $0 base_name [max_count]"
#elif [ ! -e "$base_name" ] ; then
#    fatal "Fatal: $0 - couldn't find base file '$base_name'"
fi

test -z "$max_backups" && max_backups=5000

do_rotate $base_name $max_backups
