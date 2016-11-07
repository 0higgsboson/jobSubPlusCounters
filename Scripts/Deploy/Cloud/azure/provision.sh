#!/bin/bash

source $1

for i in `seq 1 $nodes`;
  do
    if [ $i -lt 10 ]; then
        str="0"
    else
        str=""
    fi
    hostname=$cluster-$str$i
    azure network nic create -g $group -l $loc  -n $hostname-nic -m $group-vnet -k default
    azure network public-ip create $group $hostname-pip $loc
    azure network nic ip-config set -p $hostname-pip $group $hostname-nic default-ip-config
    azure network nic set -n $hostname-nic -g $group -o $nsg
    azure vm create -g $group -n $hostname -l $loc -y Linux -Q UbuntuLTS -z $vm_type -u sherpa -f $hostname-nic -M $public_key
  done
