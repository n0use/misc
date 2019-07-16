#!/bin/sh

lsof -i | awk '/^tor/ { print $9 }'  | awk -F- '{ if ($2 ~ /^>/) { gsub(/^>/, "", $2); print $2 } }' | sort
