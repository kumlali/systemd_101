#!/bin/bash

case1 () {
  while true; do
    echo [`date`] - Test message
    sleep 5
  done
}


case2 () {
  /usr/local/bin/myapplication.sh &
}


arg=$1
case "$arg" in
  case1|case2|case3)
    eval $arg
    ;;
  *)
    echo "Unknown case: " $arg
    ;;
esac


echo "startup.sh has been executed for case: $arg"
