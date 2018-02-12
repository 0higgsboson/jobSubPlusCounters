#!/bin/bash


#added configurations file as source
source configurations.sh

echo $source

echo -e "\n --- tenzig version REST call ---\n"

curl -i http://${HOST_NAME}:${PORT}/tenzing-services/api/1.0/version

echo -e "\n --- tzctcommonversion REST call ---\n"

curl -i  http://${HOST_NAME}:${PORT}/tenzing-services/api/1.0/tzctcommonversion

echo -e "\n --- jobresult REST call ---\n"

curl -i  -H "Content-Type: application/json" -X POST -d '{"clusterID":"sherpa"}' http://${HOST_NAME}:${PORT}/tenzing-services/api/1.0/jobresult

echo -e "\n --- psmanaged REST call --- \n"

curl -i  -H "Content-Type: application/json" -X POST -d '{"userName":"sherpa1","queueName":"aaaa"}' http://${HOST_NAME}:${PORT}/tenzing-services/api/1.0/psmanaged

echo -e "\n --- sync REST call --- \n"

curl -i -H "Content-Type:application/json" -X POST -d '{"clusterID":"sherpa","tenzingsSequenceNo":"99999","cluseteinfo":{"id":"0","clusterID":"sherpa","hadoopVersion":"2.7.1"} }' http://${HOST_NAME}:${PORT}/tenzing-services/api/1.0/sync

