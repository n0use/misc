#!/bin/bash
while getopts "hs:" arg; do
  case $arg in
    h)
      echo "usage: $0 [-s strength] [-h]" 
      ;;
    s)
      strength=$OPTARG
      echo $strength
      ;;
  esac
done
