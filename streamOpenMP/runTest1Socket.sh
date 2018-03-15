#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0 compilerName"
  exit 1
fi


npt=`grep -c ^processor /proc/cpuinfo`
#npt=8
np="$(($npt / 2))"
npm1="$(($np - 1))"

if [ -n "$LM_LICENSE_FILE" ]; then
    echo "Pgi Compiler"
    MP_BIND="yes"
    #MP_BLIST="0-$npm1"
    MP_BLIST="`seq 0 2 $np`"
    echo $MP_BLIST
elif [ -n "$INTEL_LICENSE_FILE" ]; then
    echo "Intel Compiler"
    export KMP_AFFINITY=compact
    # needed to use dissabled in Blue waters
    #export KMP_AFFINITY=disabled
else
    echo "Gnu Compiler"
    #GOMP_CPU_AFFINITY="0-$npm1"
    GOMP_CPU_AFFINITY="`seq 0 2 $np`"
    echo $GOMP_CPU_AFFINITY
fi  


rm -f temp.txt

for i in  `seq 1 $np`; do
    echo number of threads: $i
    export OMP_NUM_THREADS=$i
    taskset -c 0-$npm1 streamOpenMP >> temp.txt
    #taskset -c 0-$npm1 streamOpenMP >> temp.txt
done

mkdir -p ../../plots/StreamResults/$(hostname)-1Socket/$1

cat temp.txt | grep "Copy:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Copy:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)-1Socket/$1/streamOpenMP_Copy.dat

cat temp.txt | grep "Add:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Add:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)-1Socket/$1/streamOpenMP_Add.dat

cat temp.txt | grep "Scale:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Scale:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)-1Socket/$1/streamOpenMP_Scale.dat

cat temp.txt | grep "Triad:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Triad:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)-1Socket/$1/streamOpenMP_Triad.dat

rm temp.txt

