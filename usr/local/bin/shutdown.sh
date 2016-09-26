#!/bin/bash


case1 () {
  process_id=`ps -eF | grep startup.sh | grep -vw grep | awk '{print $2}'`
  kill -15 $process_id
}


case2 () {
  process_id=`ps -eF | grep myapplication.sh | grep -vw grep | awk '{print $2}'`
  kill -15 $process_id
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


echo "shutdown.sh has been executed for case: $arg"
