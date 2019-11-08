#!/bin/bash

if [ -n "$1" ] ; then
    dir=$1
else
    dir=.
fi

du -sh $dir/* | gawk '{ 
    str=$0 ; 
    size=0 ;
    name="" ;
    if (match(str, '/^[[:space:]]*\([0-9\.][0-9\.]*\)\([A-Z]\)[[:space:]]*\(.*\)$/', sz)) {
        size = sz[1]; 
        name = sz[3];
    
        if (sz[2] == "G") { 
            size = size * 1024 
        } else if (sz[2] == "K") { 
            size = size / 1024 
        } else if (sz[2] == "B") { 
            size = size / 1024 / 1024 
        } 
        printf("%.3fM (%s%s) %s\n", size, sz[1], sz[2], name);
    } else if (match(str, '/^0[[:space:]]*\(.*\)$/', sz)) {
        printf("0M (0B) %s\n", sz[1]);
    } else {
        printf("bad input [%s]\n", $0);
    }
}'  | sort -n
