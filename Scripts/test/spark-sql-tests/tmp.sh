#!/bin/bash

for i in `seq 1 30` ; do
   if (($i%15 == 0)); then
     echo d $i;
     continue;
   fi

   if (($i%3 == 0)); then
     echo b $i;
     continue;
   fi

   if (($i%5 == 0)); then
     echo c $i;
     continue;
   fi

   echo a $i;

done



