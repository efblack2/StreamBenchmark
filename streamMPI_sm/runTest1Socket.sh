#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0 compilerName"
  exit 1
fi
######################################
# modified due to problem in Blue Waters
toSkip=
toSkipM1="$(($toSkip - 1))"
toSkipP1="$(($toSkip + 1))"
#####################################

npt=`grep -c ^processor /proc/cpuinfo`
#npt=8
np="$(($npt / 2))"
npm1="$(($np - 1))"

rm -f temp.txt

for i in  `seq 1 $toSkipM1`  `seq $toSkipP1 $np` ; do
    echo number of processors: $i
    mpiexec -n $i taskset -c 0-$npm1 streamMPI_sm >> temp.txt
done

mkdir -p ../../plots/StreamResults/$(hostname)-1Socket/$1


cat temp.txt | grep "Copy:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Copy:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)-1Socket/$1/streamMPI_sm_Copy.dat

cat temp.txt | grep "Scale:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Scale:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)-1Socket/$1/streamMPI_sm_Scale.dat

cat temp.txt | grep "Add:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Add:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)-1Socket/$1/streamMPI_sm_Add.dat

cat temp.txt | grep "Triad:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Triad:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)-1Socket/$1/streamMPI_sm_Triad.dat

rm temp.txt

