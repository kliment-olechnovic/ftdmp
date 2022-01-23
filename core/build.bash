#!/bin/bash

cd "$(dirname $0)"

pwd

cd "./fftw-2.1.5"
./configure
make

cd -
cd "./3D_Dock/progs/"
make

if [ ! -s "./ftdock" ]
then
	echo "Failed to build ftdock executable in './3D_Dock/progs/'"
	exit 1
fi

cd -
cd "./FASPR"
g++ -ffast-math -O3 -o FASPR src/*.cpp

if [ ! -s "./FASPR" ]
then
	echo "Failed to build FASPR executable"
	exit 1
fi

exit 0

