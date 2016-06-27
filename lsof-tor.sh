#!/bin/sh

lsof -i | grep ^tor | awk '{ print $9 }'  | awk -F- '{ print $2 }' | grep '^>' | sort
