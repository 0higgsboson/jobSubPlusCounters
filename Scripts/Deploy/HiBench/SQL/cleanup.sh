#!/bin/bash

echo "Cleaning up existing Hive Tables ..."

hive -e "drop table uservisits_aggre"
hive -e "drop table uservisits"
hive -e "drop table rankings"
hive -e "drop table rankings_uservisits_join"
hive -e "drop table uservisits_copy"


