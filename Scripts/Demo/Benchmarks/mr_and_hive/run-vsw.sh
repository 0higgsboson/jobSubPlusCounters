#!/bin/bash


if test "$#" -ne 1; then
    echo "Usage: run-vsw.sh <workload_definitions_file>"
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
    WORKLOAD_DIR=$TEST_DIR/$workload
    input_dir=$WORKLOAD_DIR/$INPUT_DIR
    for size in "${input_sizes[@]}" ; do
	sizeinbytes=`convert_size_to_bytes $size`
#	./gen.sh $workload $sizeinbytes
#	hadoop fs -mv ${input_dir} ${input_dir}_${size}
    done
    for co in "${cost_objectives[@]}" ; do
	case $workload in
	    "wordcount" | "terasort" | "join" | "scan" | "aggregation")
		tag=${tag_base}_${workload}_VSW_${co}
		for i in `seq 1 $nontuned_iterations` ; do
		    index=`echo "($i - 1) % ${#input_sizes[@]}" | bc`
		    size=${input_sizes[$index]}
		    hadoop fs -rm -r ${input_dir}
		    hadoop fs -cp -p ${input_dir}_${size} ${input_dir}
		    ./run1job.sh $workload $tag $co false
		done
		for i in `seq 1 $tuned_iterations` ; do
		    index=`echo "($i - 1) % ${#input_sizes[@]}" | bc`
		    size=${input_sizes[$index]}
		    hadoop fs -rm -r ${input_dir}
		    hadoop fs -cp -p ${input_dir}_${size} ${input_dir}
		    ./run1job.sh $workload $tag $co true
		done
		;;
	    *)
		echo "Valid workloads: terasort|wordcount|join|aggregation|scan"
		echo "Ignoring workload: $workload"
        esac
    done
done
