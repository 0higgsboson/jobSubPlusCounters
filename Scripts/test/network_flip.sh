#!/bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 wait_seconds" >&2
  exit 1
fi
ifdown eth0
sleep $1
ifup eth0
