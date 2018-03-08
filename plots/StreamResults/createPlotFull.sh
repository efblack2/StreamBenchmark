#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0  computer"
  exit 1
fi

cd $1/gnu
paste streamMPI_sm_Copy.dat  streamOpenMP_Copy.dat > result.txt

cd ../intel
paste streamMPI_sm_Copy.dat  streamOpenMP_Copy.dat > result.txt

cd ../pgi
paste streamMPI_sm_Copy.dat  streamOpenMP_Copy.dat > result.txt

cd ../..

gnuplot -c plot.gnp $1 Copy
gnuplot -c plotRatio.gnp $1 Copy



cd $1/gnu
paste streamMPI_sm_Add.dat  streamOpenMP_Add.dat > result.txt

cd ../intel
paste streamMPI_sm_Add.dat  streamOpenMP_Add.dat > result.txt

cd ../pgi
paste streamMPI_sm_Add.dat  streamOpenMP_Add.dat > result.txt

cd ../..

gnuplot -c plot.gnp $1 Add
gnuplot -c plotRatio.gnp $1 Add



cd $1/gnu
paste streamMPI_sm_Scale.dat  streamOpenMP_Scale.dat > result.txt

cd ../intel
paste streamMPI_sm_Scale.dat  streamOpenMP_Scale.dat > result.txt

cd ../pgi
paste streamMPI_sm_Scale.dat  streamOpenMP_Scale.dat > result.txt

cd ../..

gnuplot -c plot.gnp $1 Scale
gnuplot -c plotRatio.gnp $1 Scale


cd $1/gnu
paste streamMPI_sm_Triad.dat  streamOpenMP_Triad.dat > result.txt

cd ../intel
paste streamMPI_sm_Triad.dat  streamOpenMP_Triad.dat > result.txt

cd ../pgi
paste streamMPI_sm_Triad.dat  streamOpenMP_Triad.dat > result.txt

cd ../..

gnuplot -c plot.gnp $1 Triad
gnuplot -c plotRatio.gnp $1 Triad


pdfunite $1-Copy.pdf $1-CopyRatio.pdf $1-Scale.pdf $1-ScaleRatio.pdf $1-Add.pdf $1-AddRatio.pdf $1-Triad.pdf $1-TriadRatio.pdf $1.pdf
rm $1-Copy.pdf $1-CopyRatio.pdf $1-Scale.pdf $1-ScaleRatio.pdf $1-Add.pdf $1-AddRatio.pdf $1-Triad.pdf $1-TriadRatio.pdf 

rm `find . -name result*.txt`















