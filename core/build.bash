#!/bin/bash

cd "$(dirname $0)"

pwd

cd "./fftw-2.1.3"

./configure
make

cd -

cd "./3D_Dock/progs/"

make

if [ ! -s "./ftdock" ] || [ ! -s "./build" ] || [ ! -s "./randomspin" ]
then
	echo "Failed to build executables in './3D_Dock/progs/'"
	exit 1
fi

exit 0

