#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

#NAMENODE_URL=hdfs://akhtar-08ay:9000
NAMENODE_URL=hdfs://sherpa:9000
HADOOP_EXAMPLES_JAR=${CWD}/libs/hadoop-mapreduce-examples-2.7.2.jar
AUTOGEN_JAR=${CWD}/libs/autogen-5.0-SNAPSHOT-jar-with-dependencies.jar
MAHOUT_HOME=${CWD}/libs/mahout-distribution-0.9/


TAG_PREFIX=June_30_2016
COST_OBJECTIVE=Memory
QUEUE_NAME=default


#Wordcount
# datasize=> bytes of data
hibench_wordcount_tiny_datasize=32000
hibench_wordcount_small_datasize=320000000
hibench_wordcount_large_datasize=3200000000
hibench_wordcount_huge_datasize=32000000000
hibench_wordcount_gigantic_datasize=320000000000
hibench_wordcount_bigdata_datasize=1600000000000

#Aggregation
hibench_aggregation_tiny_uservisits=1000
hibench_aggregation_tiny_pages=120
hibench_aggregation_small_uservisits=100000
hibench_aggregation_small_pages=12000
hibench_aggregation_large_uservisits=1000000
hibench_aggregation_large_pages=120000
hibench_aggregation_huge_uservisits=10000000
hibench_aggregation_huge_pages=1200000
hibench_aggregation_gigantic_uservisits=100000000
hibench_aggregation_gigantic_pages=12000000
hibench_aggregation_bigdata_uservisits=1000000000
hibench_aggregation_bigdata_pages=100000000

#Scan
hibench_scan_tiny_uservisits=1000
hibench_scan_tiny_pages=120
hibench_scan_small_uservisits=100000
hibench_scan_small_pages=12000
hibench_scan_large_uservisits=1000000
hibench_scan_large_pages=120000
hibench_scan_huge_uservisits=10000000
hibench_scan_huge_pages=1200000
hibench_scan_gigantic_uservisits=100000000
hibench_scan_gigantic_pages=12000000
hibench_scan_bigdata_uservisits=2000000000
hibench_scan_bigdata_pages=10000000


#Join
hibench_join_tiny_uservisits=1000
hibench_join_tiny_pages=120
hibench_join_small_uservisits=100000
hibench_join_small_pages=12000
hibench_join_large_uservisits=1000000
hibench_join_large_pages=120000
hibench_join_huge_uservisits=10000000
hibench_join_huge_pages=1200000
hibench_join_gigantic_uservisits=100000000
hibench_join_gigantic_pages=12000000
hibench_join_bigdata_uservisits=5000000000
hibench_join_bigdata_pages=120000000

#Sort
# datasize=> bytes of data
hibench_sort_tiny_datasize=32000
hibench_sort_small_datasize=3200000
hibench_sort_large_datasize=320000000
hibench_sort_huge_datasize=3200000000
hibench_sort_gigantic_datasize=32000000000
hibench_sort_bigdata_datasize=300000000000

#Terasort
# datasize=> record number of data, 100 bytes per record
hibench_terasort_tiny_datasize=32000
hibench_terasort_small_datasize=3200000
hibench_terasort_large_datasize=32000000
hibench_terasort_huge_datasize=320000000
hibench_terasort_gigantic_datasize=3200000000
hibench_terasort_bigdata_datasize=6000000000

#Bayes
hibench_bayes_tiny_pages=25000
hibench_bayes_tiny_classes=10
hibench_bayes_tiny_ngrams=1
hibench_bayes_small_pages=30000
hibench_bayes_small_classes=100
hibench_bayes_small_ngrams=2
hibench_bayes_large_pages=100000
hibench_bayes_large_classes=100
hibench_bayes_large_ngrams=2
hibench_bayes_huge_pages=500000
hibench_bayes_huge_classes=100
hibench_bayes_huge_ngrams=2
hibench_bayes_gigantic_pages=1000000
hibench_bayes_gigantic_classes=100
hibench_bayes_gigantic_ngrams=2
hibench_bayes_bigdata_pages=20000000
hibench_bayes_bigdata_classes=20000
hibench_bayes_bigdata_ngrams=2

#Kmeans
hibench_kmeans_tiny_num_of_clusters=5
hibench_kmeans_tiny_dimensions=3
hibench_kmeans_tiny_num_of_samples=30000
hibench_kmeans_tiny_samples_per_inputfile=6000
hibench_kmeans_tiny_max_iteration=5
hibench_kmeans_tiny_k=10
hibench_kmeans_tiny_convergedist=0.5
hibench_kmeans_small_num_of_clusters=5
hibench_kmeans_small_dimensions=20
hibench_kmeans_small_num_of_samples=3000000
hibench_kmeans_small_samples_per_inputfile=600000
hibench_kmeans_small_max_iteration=5
hibench_kmeans_small_k=10
hibench_kmeans_small_convergedist=0.5
hibench_kmeans_large_num_of_clusters=5
hibench_kmeans_large_dimensions=20
hibench_kmeans_large_num_of_samples=20000000
hibench_kmeans_large_samples_per_inputfile=4000000
hibench_kmeans_large_max_iteration=5
hibench_kmeans_large_k=10
hibench_kmeans_large_convergedist=0.5
hibench_kmeans_huge_num_of_clusters=5
hibench_kmeans_huge_dimensions=20
hibench_kmeans_huge_num_of_samples=100000000
hibench_kmeans_huge_samples_per_inputfile=20000000
hibench_kmeans_huge_max_iteration=5
hibench_kmeans_huge_k=10
hibench_kmeans_huge_convergedist=0.5
hibench_kmeans_gigantic_num_of_clusters=5
hibench_kmeans_gigantic_dimensions=20
hibench_kmeans_gigantic_num_of_samples=200000000
hibench_kmeans_gigantic_samples_per_inputfile=40000000
hibench_kmeans_gigantic_max_iteration=5
hibench_kmeans_gigantic_k=10
hibench_kmeans_gigantic_convergedist=0.5
hibench_kmeans_bigdata_num_of_clusters=5
hibench_kmeans_bigdata_dimensions=20
hibench_kmeans_bigdata_num_of_samples=1200000000
hibench_kmeans_bigdata_samples_per_inputfile=40000000
hibench_kmeans_bigdata_max_iteration=10
hibench_kmeans_bigdata_k=10
hibench_kmeans_bigdata_convergedist=0.5


function run(){
    local CMD=$1
    local is_parallel=$2

    echo "Running Command: ${CMD}"
    if [[ "${is_parallel}" = "yes"  ]];
    then
        ${CMD} &
    else
        ${CMD}
    fi
}


function wordcount_prepare(){
    local jar=$1
    local data_profile=$2
    local input_dir=$3

    local data_profile_name="hibench_wordcount_${data_profile}_datasize"
    local data_size=${!data_profile_name}

    local CMD="hadoop jar ${jar} randomtextwriter -D mapreduce.randomtextwriter.totalbytes=${data_size}  -D mapreduce.job.maps=12 -D mapreduce.job.reduces=6 -D mapreduce.output.fileoutputformat.compress=false     ${input_dir}"

    run "${CMD}" "no"
}


function wordcount_run(){
    local jar=$1
    local input=$2
    local output=$3
    local ps_managed=$4
    local tag=$5

    local CMD="hadoop jar ${jar} wordcount -D mapreduce.output.fileoutputformat.compress=false
    -D mapreduce.inputformat.class=org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat
    -D mapreduce.outputformat.class=org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat
    -D mapreduce.job.inputformat.class=org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat
    -D mapreduce.job.outputformat.class=org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat
    -D PSManaged=${ps_managed} -D Tag=${tag}  -D SherpaCostObj=${COST_OBJECTIVE} -D mapreduce.job.queuename=${QUEUE_NAME}  ${input}  ${output}"

    run "${CMD}" "yes"
}











function sort_prepare(){
    local jar=$1
    local data_profile=$2
    local input_dir=$3
    local data_profile_name="hibench_sort_${data_profile}_datasize"
    local data_size=${!data_profile_name}

    local CMD="hadoop jar ${jar} randomtextwriter -D mapreduce.randomtextwriter.totalbytes=${data_size}  -D mapreduce.job.maps=12 -D mapreduce.job.reduces=6 -D mapreduce.output.fileoutputformat.compress=false     ${input_dir}"

    run "${CMD}" "no"
}


function sort_run(){
    local jar=$1
    local input=$2
    local output=$3
    local ps_managed=$4
    local tag=$5

    local CMD="hadoop jar ${jar} sort -D mapreduce.output.fileoutputformat.compress=false  -D PSManaged=${ps_managed} -D Tag=${tag}  -D SherpaCostObj=${COST_OBJECTIVE} -D mapreduce.job.queuename=${QUEUE_NAME} -outKey org.apache.hadoop.io.Text -outValue org.apache.hadoop.io.Text    ${input}  ${output}"

    run "${CMD}" "yes"
}









function terasort_prepare(){
    local jar=$1
    local data_profile=$2
    local input_dir=$3

    local data_profile_name="hibench_terasort_${data_profile}_datasize"
    local data_size=${!data_profile_name}

    local CMD="hadoop jar ${jar} teragen -Dmapreduce.job.maps=12 -Dmapreduce.job.reduces=12   ${data_size}   ${input_dir}"

    run "${CMD}" "no"
}


function terasort_run(){
    local jar=$1
    local input=$2
    local output=$3
    local ps_managed=$4
    local tag=$5

    local CMD="hadoop jar ${jar} terasort -D mapreduce.terasort.simplepartitioner=true -D PSManaged=${ps_managed} -D Tag=${tag} -D SherpaCostObj=${COST_OBJECTIVE} -D mapreduce.job.queuename=${QUEUE_NAME}  ${input}  ${output}"

    run "${CMD}" "yes"
}

















function sql_prepare(){
    local jar=$1
    local data_profile=$2
    local base_dir=$3
    local input_dir=$4

    local uservisits_name="hibench_scan_${data_profile}_uservisits"
    local uservisits=${!uservisits_name}
    local pages_name="hibench_scan_${data_profile}_pages"
    local pages=${!pages_name}

    local CMD="hadoop jar ${jar} HiBench.DataGen -t hive -b  ${base_dir} -n ${input_dir} -m 12  -r 6  -p ${pages}  -v ${uservisits} -o sequence"

    find . -name "metastore_db" -exec rm -rf "{}" \; 2>/dev/null
    run "${CMD}" "no"
}


function scan_run(){
   local HIVEBENCH_SQL_FILE=$1
   local INPUT_HDFS=$2
   local OUTPUT_HDFS=$3
   local ps_managed=$4
   local tag=$5


    cat <<EOF > scan/${HIVEBENCH_SQL_FILE}

USE DEFAULT;
set hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
set hive.stats.autogather=false;
drop table if exists ${HIVEBENCH_SQL_FILE};
drop table if exists ${HIVEBENCH_SQL_FILE}_copy;
CREATE EXTERNAL TABLE ${HIVEBENCH_SQL_FILE}      (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS SEQUENCEFILE LOCATION '$INPUT_HDFS/uservisits';
CREATE EXTERNAL TABLE ${HIVEBENCH_SQL_FILE}_copy (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS SEQUENCEFILE LOCATION '$OUTPUT_HDFS/uservisits_copy';
INSERT OVERWRITE TABLE ${HIVEBENCH_SQL_FILE}_copy SELECT * FROM ${HIVEBENCH_SQL_FILE};
EOF


    CMD="$HIVE_HOME/bin/hive  -hiveconf PSManaged=${ps_managed} -hiveconf Tag=${tag}  -hiveconf SherpaCostObj=${COST_OBJECTIVE} -hiveconf mapreduce.job.queuename=${QUEUE_NAME} -f scan/${HIVEBENCH_SQL_FILE}"
    run "${CMD}" "yes"

}


function aggregation_run(){
   local HIVEBENCH_SQL_FILE=$1
   local INPUT_HDFS=$2
   local OUTPUT_HDFS=$3
   local ps_managed=$4
   local tag=$5


    cat <<EOF > aggregation/${HIVEBENCH_SQL_FILE}

USE DEFAULT;
set hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
set hive.stats.autogather=false;
drop table if exists ${HIVEBENCH_SQL_FILE};
drop table if exists ${HIVEBENCH_SQL_FILE}_aggre;
CREATE EXTERNAL TABLE ${HIVEBENCH_SQL_FILE}       ( sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS SEQUENCEFILE LOCATION '$INPUT_HDFS/uservisits';
CREATE EXTERNAL TABLE ${HIVEBENCH_SQL_FILE}_aggre ( sourceIP STRING, sumAdRevenue DOUBLE) STORED AS SEQUENCEFILE LOCATION '$OUTPUT_HDFS/uservisits_aggre';
INSERT OVERWRITE TABLE ${HIVEBENCH_SQL_FILE}_aggre SELECT sourceIP, SUM(adRevenue) FROM ${HIVEBENCH_SQL_FILE} GROUP BY sourceIP;
EOF

    CMD="$HIVE_HOME/bin/hive  -hiveconf PSManaged=${ps_managed} -hiveconf Tag=${tag}  -hiveconf SherpaCostObj=${COST_OBJECTIVE} -hiveconf mapreduce.job.queuename=${QUEUE_NAME} -f aggregation/${HIVEBENCH_SQL_FILE}"
    run "${CMD}" "yes"

}



function join_run(){
   local HIVEBENCH_SQL_FILE=$1
   local INPUT_HDFS=$2
   local OUTPUT_HDFS=$3
   local ps_managed=$4
   local tag=$5

    cat <<EOF > join/${HIVEBENCH_SQL_FILE}

USE DEFAULT;
set hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
set hive.stats.autogather=false;
drop table if exists ${HIVEBENCH_SQL_FILE}_rankings;
drop table if exists ${HIVEBENCH_SQL_FILE}_uservisits_copy;
drop table if exists ${HIVEBENCH_SQL_FILE}_rankings_uservisits_join;


CREATE EXTERNAL TABLE ${HIVEBENCH_SQL_FILE}_rankings (pageURL STRING, pageRank INT, avgDuration INT) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS SEQUENCEFILE LOCATION '$INPUT_HDFS/rankings';
CREATE EXTERNAL TABLE ${HIVEBENCH_SQL_FILE}_uservisits_copy (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS SEQUENCEFILE LOCATION '$INPUT_HDFS/uservisits';
CREATE EXTERNAL TABLE ${HIVEBENCH_SQL_FILE}_rankings_uservisits_join ( sourceIP STRING, avgPageRank DOUBLE, totalRevenue DOUBLE) STORED AS SEQUENCEFILE LOCATION '$OUTPUT_HDFS/${HIVEBENCH_SQL_FILE}_rankings_uservisits_join';
INSERT OVERWRITE TABLE ${HIVEBENCH_SQL_FILE}_rankings_uservisits_join SELECT sourceIP, avg(pageRank), sum(adRevenue) as totalRevenue FROM ${HIVEBENCH_SQL_FILE}_rankings R JOIN (SELECT sourceIP, destURL, adRevenue FROM ${HIVEBENCH_SQL_FILE}_uservisits_copy UV WHERE (datediff(UV.visitDate, '1999-01-01')>=0 AND datediff(UV.visitDate, '2000-01-01')<=0)) NUV ON (R.pageURL = NUV.destURL) group by sourceIP order by totalRevenue DESC;
EOF





    CMD="$HIVE_HOME/bin/hive  -hiveconf PSManaged=${ps_managed} -hiveconf Tag=${tag}  -hiveconf SherpaCostObj=${COST_OBJECTIVE} -hiveconf mapreduce.job.queuename=${QUEUE_NAME} -f join/${HIVEBENCH_SQL_FILE}"
    run "${CMD}" "yes"

}









function create_dir(){
    dir=$1
    hdfs dfs -mkdir -p ${dir}
}

function driver(){
    START=$(date +%s)

    local workload_name=$1
    local data_profile=$2
    local no_of_instances=$3
    local iterations=$4
    TAG_PREFIX=$5

    local uuid=$(uuidgen)
    local ps_managed=true

    #local in_dt=$(date +"%Y-%m-%d-%H-%M-%S")
    local base_input_path=${NAMENODE_URL}/${workload_name}/input
    local input_path=${base_input_path}/${uuid}/
    #echo "Creating dir: ${input_path}"
    #create_dir ${input_dir}

    local create_new_input=true


    for i in `seq 1 ${iterations}`;
    do
       echo ""
       echo "Iteration $i of $iterations ..."
       echo "------------------------------------------------------------------------------------------------------------------------------------------------------------"


        if [[ "${i}" -eq 1 ]];
        then
            ps_managed=false
        else
            ps_managed=true
        fi


        for instance_id in `seq 1 ${no_of_instances}`;
        do

           echo ""
           echo "Iteration $i of $iterations: Instance $instance_id of $no_of_instances "
           echo "-------------------------------------------------------------------------"


           local tag=${TAG_PREFIX}_instance-${instance_id}_${workload_name}_${COST_OBJECTIVE}_${data_profile}


           #local out_dt=$(date +"%Y-%m-%d-%H-%M-%S")
           local output_path=${NAMENODE_URL}/${workload_name}/output/${uuid}/${instance_id}_${i}/


           if [[ "${workload_name}" = "wordcount" || "${workload_name}" = "sort" || "${workload_name}" = "terasort"  ]];
            then
                   if [[ "${create_new_input}" = "true"  ]];
                    then
                        echo ""
                        echo "Preparing ${workload_name} Data"
                        echo "--------------------------------"
                        eval ${workload_name}_prepare ${HADOOP_EXAMPLES_JAR} ${data_profile} ${input_path}
                        create_new_input=false
                    fi

                    eval ${workload_name}_run   ${HADOOP_EXAMPLES_JAR}  ${input_path} ${output_path}  ${ps_managed} ${tag}







           elif [[ "${workload_name}" = "scan"  || "${workload_name}" = "aggregation"  || "${workload_name}" = "join"     ]];
            then
                   if [[ "${create_new_input}" = "true"  ]];
                    then
                        echo ""
                        echo "Preparing ${workload_name} Data"
                        echo "--------------------------------"
                        sql_prepare ${AUTOGEN_JAR} ${data_profile} ${base_input_path}  ${uuid}
                        create_new_input=false
                        mkdir -p ${workload_name}/${instance_id}
                    fi


                    eval ${workload_name}_run   table_${instance_id}  ${input_path} ${output_path}  ${ps_managed} ${tag}  ${instance_id}



            fi








        done

        wait
        echo ""
        echo "******* Instances Iteration done"
        echo ""



    done

    local in=${NAMENODE_URL}/${workload_name}/input/${uuid}/
    local out=${NAMENODE_URL}/${workload_name}/output/${uuid}
    hdfs dfs -rm -r -skipTrash ${in}
    hdfs dfs -rm -r -skipTrash ${out}


    wait
    END=$(date +%s)
    DIFF=$(( $END - $START ))
    echo "It took $DIFF seconds"
    echo "$(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds elapsed."

}



if [ $# -ne 5 ]
  then
  echo "Usage:  ./hibench_throughput.sh   workload_name   data_profile  number_of_instances    number_of_iterations   tag"
  exit
fi

driver $1 $2 $3 $4 $5