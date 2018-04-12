#!/bin/bash


# load configurations & utils functions
source configurations.sh

echo $source


echo -e "\n --- tenzig version REST call ---\n"
sleep 3
echo -e "# REST URL: http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/version \n"

curl -i http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/version

echo -e "\n\n  --- tzctcommonversion REST call ---\n"
sleep 3
echo -e "# REST URL: http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/tzctcommonversion \n"

curl -i  http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/tzctcommonversion

echo -e "\n\n --- jobresult REST call ---\n"
sleep 3
echo -e "# REST URL: http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/jobresult \n"

curl -i  -H "Content-Type: application/json" -X POST -d '{"clusterID":"sherpa"}' http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/jobresult

echo -e "\n\n --- psmanaged REST call --- \n"
sleep 3
echo -e "# REST URL: http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/psmanaged \n"

curl -i  -H "Content-Type: application/json" -X POST -d '{"userName":"sherpa1","queueName":"aaaa"}' http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/psmanaged


echo -e "\n\n --- sync REST call --- \n"
sleep 3
echo -e "# REST URL:  http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/sync \n" 

curl -i -H "Content-Type:application/json" -X POST -d '{"clusterID":"sherpa","tenzingsSequenceNo":"99999","cluseteinfo":{"id":"0","clusterID":"sherpa","hadoopVersion":"2.7.1"} }' http://${TENZING_HOST_NAME}:${TENZING_PORT}/tenzing-services/api/1.0/sync


echo -e "\n\n --- heartbeat REST call --- \n"
sleep 3
echo -e "# RESt URL:  http://${TENZING_HOST_NAME}:${TENZING_PORT}/ca-services/api/1.0/heartbeat \n"

curl -i  -H "Content-Type: application/json" -X POST -d '{"configsServed":"2","metadataReceived":"5","heartbeatInterval":"10","clusterID":"sherpa","timestamp":"1342049220104L"}' http://${TENZING_HOST_NAME}:${TENZING_PORT}/ca-services/api/1.0/heartbeat


echo -e "\n\n ------ CA Service REST API Call Starts  -------\n\n"

echo -e " --- CA service REST call --- \n"
sleep 3
echo -e "# REST URL: http://${CA_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/version \n"

curl -i http://${TENZING_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/version

echo -e "\n\n --- tzctcommonversion REST Call --- \n"
sleep 3
echo -e "# RESt URL: http://${CA_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/tzctcommonversion \n"

curl -i http://${CA_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/tzctcommonversion

echo -e "\n\n --- tunedparams REST call --- \n"
sleep 3
echo -e "# REST URL: http://${CA_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/tunedparams \n"

curl -i -H "Content-Type:application/json" -X POST -d '{"workloadId":"sherpa","clientType":"CA"}' http://${TENZING_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/tunedparams

echo -e "\n\n --- jobresult REST call --- \n"
sleep 3
echo -e "# REST URL: http://${CA_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/jobresult  \n"

curl -i  -H "Content-Type: application/json" -X POST -d '{"clusterID":"sherpa"}' http://${CA_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/jobresult

echo -e "\n\n --- psmanaged REST call --- \n"
sleep 3
echo -e "# REST URL: http://${CA_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/psmanaged  \n"

curl -i  -H "Content-Type: application/json" -X POST -d '{"userName":"sherpa1","queueName":"aaaa"}' http://${CA_HOST_NAME}:${CA_PORT}/ca-services/api/1.0/psmanaged

echo -e "\n\n"

