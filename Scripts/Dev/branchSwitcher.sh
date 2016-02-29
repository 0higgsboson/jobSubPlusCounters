#!/bin/bash

if [ $# -eq 1 ]
  then
    branch=$1
  else
    echo "Branch name arguement is required"
    exit
fi

echo "Switching to branch: $branch "

function switchBranch(){
  path=$1
  echo "******************************************************** Repo: $path"
  cd $path
  echo "----------Current Branch:"
  git branch
  echo ""
  echo "----------Repo Status: "
  git status
  git checkout $branch
  echo ""
  echo "----------Current Branch: "
  git branch
}
	

switchBranch "/root/sherpa/jobSubPub_src/jobSubPlusCounters/"
switchBranch "/root/sherpa/tzCtCommon/TzCtCommon/"
switchBranch "/root/sherpa/mr_client_src/mrClient/"
switchBranch "/root/sherpa/hive_client_src/hiveClientSherpa/"
