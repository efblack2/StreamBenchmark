#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0 compilerName"
  exit 1
fi


npt=`grep -c ^processor /proc/cpuinfo`
numaNodes=`lscpu | grep "NUMA node(s):" | awk '{}{print $3}{}'`
tpc=`lscpu | grep "Thread(s) per core:" | awk '{}{print $4}{}'`
np="$(($npt / $tpc))"
npps="$(($np / $numaNodes))"
npm1="$(($np - 1))"
tps=$((npps*tpc))

if [ -n "$PGI" ]; then
    echo "Pgi Compiler"
elif [ -n "$INTEL_LICENSE_FILE" ]; then
    echo "Intel Compiler"
else
    echo "Gnu Compiler"
fi

seqArray=()
##########################################
k=0
for i in  `seq 0 $((npps-1))`; do
    kk=$((k))
    for j in `seq 0 $((numaNodes-1))`; do
        seqArray[i*$numaNodes+j]=$((kk))
	kk=$((kk+tps))
    done
    k=$((k+tpc))
done
##########################################

#echo ${seqArray[*]}
sequence=''
for p in `seq 0 $((  npm1  ))`; do
    sequence+=${seqArray[p]}','
done
sequence=${sequence%?}
#echo $sequence

rm -f temp.txt

for i in 1 2 `seq 4 1 $np`; do
    echo number of processors: $i 
    aprun  -cc $sequence   -n $i -N $i  streamMPI_sm >> temp.txt
done

mkdir -p ../../plots/StreamResults/$(hostname)/$1

cat temp.txt | grep "Copy:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Copy:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamMPI_sm_Copy.dat

cat temp.txt | grep "Scale:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Scale:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamMPI_sm_Scale.dat

cat temp.txt | grep "Add:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Add:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamMPI_sm_Add.dat

cat temp.txt | grep "Triad:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Triad:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamMPI_sm_Triad.dat


rm temp.txt

