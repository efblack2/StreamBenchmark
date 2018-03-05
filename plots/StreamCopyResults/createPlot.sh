#!/bin/bash
if [ "$#" -ne 1 ]
then
  echo "Usage: $0  computer"
  exit 1
fi

cd $1/gnu
paste streamMPI_sm.dat  streamOpenMP.dat > result.txt

cd ../intel
paste streamMPI_sm.dat  streamOpenMP.dat > result.txt

cd ../pgi
paste streamMPI_sm.dat  streamOpenMP.dat > result.txt


cd ../..

gnuplot -c plot.gnp $1 
gnuplot -c plotRatio.gnp $1

rm `find . -name result*.txt`

