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
sockets=`lscpu | grep Socket | awk '{}{print $2}{}'`
tpc=`lscpu | grep -i thread | awk '{}{print $4}{}'`
np="$(($npt / $tpc))"
npps="$(($np / $sockets))"
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
elif [ -n "$INTEL_LICENSE_FILE" ]; then
    echo "Intel Compiler"
else
    echo "Gnu Compiler"
fi  

rm -f temp.txt

for i in  `seq 1 $toSkipM1`  `seq $toSkipP1 $np` ; do
    echo number of processors: $i
    mpiexec -n $i streamMPI_sm >> temp.txt
done

mkdir -p ../../plots/StreamResults/$(hostname)/$1

cat temp.txt | grep "Copy:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Copy:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamMPI_sm_Copy.dat

cat temp.txt | grep "Scale:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Scale:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamMPI_sm_Scale.dat

cat temp.txt | grep "Add:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Add:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamMPI_sm_Add.dat

cat temp.txt | grep "Triad:\|counted" | awk ' BEGIN {i=0;j=0}   { if ($4 == "counted") np[i++]=$6;  if ($1 == "Triad:")rate[j++]=$2;}   END {for (j=0; j<i; ++j) printf("%d %.1f\n",  np[j], rate[j])}' > ../../plots/StreamResults/$(hostname)/$1/streamMPI_sm_Triad.dat


rm temp.txt

