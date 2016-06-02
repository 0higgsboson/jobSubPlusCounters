#!/bin/bash

for i in `seq 1 100000` ;
do
    date
    hadoop job -list all | grep RUNNING | more ; date
    sleep 10
done

