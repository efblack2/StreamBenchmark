#!/bin/bash
if [ "$#" -ne 1 ] 
then
  echo "Usage: $0 compilerName"
  exit 1
fi

npt=`grep -c ^processor /proc/cpuinfo`
#npt=8
np="$(($npt / 2))"
rm -f temp.txt

for i in  `seq 1 $np`; do
    echo number of processors: $i
    mpiexec -n $i streamMPI_sm >> temp.txt
done

mkdir -p ../../plots/StreamCopyResults/$(hostname)/$1

cat temp.txt | grep "Copy:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Copy:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamCopyResults/$(hostname)/$1/streamMPI_sm.dat

rm temp.txt


