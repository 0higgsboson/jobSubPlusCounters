#!/bin/bash


if test "$#" -ne 1; then
    echo "Usage: run.sh <workload_definitions_file>"
    exit 1
fi

source ./configurations.sh
source $1


convert_size_to_bytes() {
    sb=$1
    sb=`echo $sb | tr 'A-Z' 'a-z' | tr 'b' ' ' | awk '{sub("k","000"); sub("m","000000"); sub("g","000000000"); sub("t","000000000000"); print}'`
    echo $sb
}


for workload in "${workloads[@]}" ; do
    for size in "${input_sizes[@]}" ; do
	sizeinbytes=`convert_size_to_bytes $size`
	./gen.sh $workload $sizeinbytes
	for co in "${cost_objectives[@]}" ; do
	    case $workload in
		"wordcount" | "terasort" | "join" | "scan" | "aggregation")
		    tag=${tag_base}_${workload}_${size}_${co}
		    for i in `seq 1 $nontuned_iterations` ; do
			./run1job.sh $workload $tag $co false
		    done
		    for i in `seq 1 $tuned_iterations` ; do
			./run1job.sh $workload $tag $co true
		    done
		    ;;
		*)
		    echo "Valid workloads: terasort|wordcount|join|aggregation|scan"
		    echo "Ignoring workload: $workload"
            esac
	done
    done
done
