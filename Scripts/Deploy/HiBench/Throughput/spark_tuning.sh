#!/bin/bash

driver="1G"
#memory=("1G" "2G" "3G" "4G" "5g" "6g")

executors=("1" "2" "3" "4" "5")
cores=("1" "2" "3" "4")
memory=("128m" "256m" "512m" "712m" "1G" "2G")
res=()

for executor in "${executors[@]}"
do
for core in "${cores[@]}"
do
for mem in "${memory[@]}"
do
    START=$(date +%s)
    echo "Running for $core $mem  $driver $executor"
    ./run.sh $core $mem  $driver $executor


    END=$(date +%s)
    DIFF=$(( $END - $START ))
    echo "It took $DIFF seconds"
    echo "$(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds elapsed."
    str="${core},${mem},${executor},${DIFF}"
    res+=(${str})
done


echo "Printing Results ...."
for r in "${res[@]}"
do
    echo "${r} sec"
done
done
done