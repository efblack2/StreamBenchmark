#!/bin/bash
if [ "$#" -lt 1 ] 
then
  echo "Usage: $0 compilerName [Copy | Scale | Add | Triad]"
  exit 1
fi

if [ -z "$2" ]; then
    test='Copy'
else
    test=$2
fi

npt=`grep -c ^processor /proc/cpuinfo`
#npt=8
np="$(($npt / 2))"
npm1="$(($np - 1))"

rm -f temp.txt

for i in  `seq 1 $np`; do
    echo number of processors: $i
    mpiexec -n $i taskset -c 0-$npm1 streamMPI_sm >> temp.txt
done

mkdir -p ../../plots/StreamCopyResults/$(hostname)-1Socket/$1


cat temp.txt | grep "$test:\|counted" | awk -v myTest=$test: ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == myTest)rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > > ../../plots/StreamCopyResults/$(hostname)-1Socket/$1/streamMPI_sm_$test.dat

rm temp.txt

