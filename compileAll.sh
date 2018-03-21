#!/bin/bash

mkdir -p  streamMPI_sm/buildGnu
mkdir -p  streamOpenMP/buildGnu

mkdir -p  streamMPI_sm/buildIntel
mkdir -p  streamOpenMP/buildIntel

mkdir -p  streamMPI_sm/buildPgi
mkdir -p  streamOpenMP/buildPgi

cd streamOpenMP/buildGnu
cmake ..; make
cd ../../streamMPI_sm/buildGnu
cmake ..; make
cd ../../

export CC=icc
export CXX=icpc
source setIcc intel64 
source setImpi

cd streamOpenMP/buildIntel
cmake ..; make
cd ../../streamMPI_sm/buildIntel
cmake ..; make
cd ../../

export CC=pgcc
export CXX=pgc++
source setPgi 18.1
source setPgiMpi 18.1

cd streamOpenMP/buildPgi
cmake ..; make
cd ../../streamMPI_sm/buildPgi
cmake ..; make
cd ../../

