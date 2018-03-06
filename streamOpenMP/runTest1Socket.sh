#!/bin/bash
if [ "$#" -ne 1 ] 
then
  echo "Usage: $0 compilerName"
  exit 1
fi

npt=`grep -c ^processor /proc/cpuinfo`
#npt=8
np="$(($npt / 2))"
npm1="$(($np - 1))"

rm -f temp.txt

for i in  `seq 1 $np`; do
    echo number of threads: $i
    export OMP_NUM_THREADS=$i
    taskset -c 0-$npm1 streamOpenMP >> temp.txt
done

mkdir -p ../../plots/StreamCopyResults/$(hostname)-1Socket/$1


cat temp.txt | grep "Copy:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Copy:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamCopyResults/$(hostname)-1Socket/$1/streamOpenMP.dat

rm temp.txt
