#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

################################################################################

cd "${SCRIPTDIR}/fftw-2.1.5"
./configure
make

################################################################################

cd "${SCRIPTDIR}/3D_Dock/progs/"
make

if [ ! -s "./ftdock" ]
then
	echo "Failed to build ftdock executable in './3D_Dock/progs/'"
	exit 1
fi

################################################################################

cd "${SCRIPTDIR}/voronota/expansion_js"
g++ -std=c++14 -I"./src/dependencies" -O3 -o "./voronota-js" $(find ./src/ -name '*.cpp')

if [ ! -s "./voronota-js" ]
then
	echo "Failed to build voronota-js executable"
	exit 1
fi

################################################################################

exit 0

