#!/bin/bash


#added configurations file as source
source configurations.sh

echo $source

curl -i http://$HOST_NAME:$PORT/tenzing-services/api/1.0/version

curl -i  http://${HOST_NAME}:${PORT}/tenzing-services/api/1.0/tzctcommonversion

curl -i  -H "Content-Type: application/json" -X POST -d '{"clusterID":"sherpa"}' http://${HOST_NAME}:${PORT}/tenzing-services/api/1.0/jobresult

curl -i  -H "Content-Type: application/json" -X POST -d '{"userName":"sherpa1","queueName":"aaaa"}' http://${HOST_NAME}:${PORT}/tenzing-services/api/1.0/psmanaged

curl -i -H "Content-Type:application/json" -X POST -d '{"clusterID":"sherpa","tenzingsSequenceNo":"99999","cluseteinfo":{"id":"0","clusterID":"sherpa","hadoopVersion":"2.7.1"} }' http://${HOST_NAME}:${PORT}/tenzing-services/api/1.0/sync

