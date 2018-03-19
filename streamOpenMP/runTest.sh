#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0 compilerName"
  exit 1
fi

npt=`grep -c ^processor /proc/cpuinfo`
np="$(($npt / 1))"
slots=`numactl -H | grep available | awk '{}{print $2}{}'`
npps="$(($np / $slots))"
npm1="$(($np - 1))"


sequence=''
##########################################
for i in  `seq 0 $((npps-1))`; do
    sequence+=$i','
    sequence+=$(($i +  $((np/2))  ))','
done
##########################################
#for i in `seq 0 $((npm1))`; do
#    sequence+=$i','
#done
##########################################
#for i in `seq 0 2 $((npm1))`; do
#    sequence+=$i','
#done
#for i in `seq 1 2 $((npm1))`; do
#    sequence+=$i','
#done
##########################################

sequence=${sequence%?}
echo $sequence
if [ -n "$LM_LICENSE_FILE" ]; then
    echo "Pgi Compiler"
    export MP_BIND="yes"
    export MP_BLIST=$sequence
    #export MP_BLIST="0-$npm1"
    echo $MP_BLIST
elif [ -n "$INTEL_LICENSE_FILE" ]; then
    echo "Intel Compiler"
    export OMP_PLACES=sockets
    export OMP_PROC_BIND=true
    #export KMP_AFFINITY=scatter
    # needed to use dissabled in Blue waters
    #export KMP_AFFINITY=disabled
else
    echo "Gnu Compiler"
    #export OMP_PLACES=sockets
    #export OMP_PROC_BIND=true
    export GOMP_CPU_AFFINITY=$sequence
    #export GOMP_CPU_AFFINITY="0-$npm1"
fi

rm -f temp.txt
for i in  `seq 1 $np`; do
    echo number of threads: $i
    export OMP_NUM_THREADS=$i
    streamOpenMP >> temp.txt
done

mkdir -p ../../plots/StreamResults/$(hostname)/$1

cat temp.txt | grep "Copy:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Copy:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamOpenMP_Copy.dat

cat temp.txt | grep "Scale:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Scale:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamOpenMP_Scale.dat

cat temp.txt | grep "Add:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Add:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamOpenMP_Add.dat

cat temp.txt | grep "Triad:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Triad:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamOpenMP_Triad.dat

rm temp.txt
