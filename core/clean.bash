#!/bin/bash

SCRIPTDIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

################################################################################

cd "${SCRIPTDIR}/fftw-2.1.5"
pwd
make clean
find ./ -type f -name 'Makefile' | while read MFILE
do
	rm "$MFILE"
done
rm -f "./config.log" "./config.status"

################################################################################

cd "${SCRIPTDIR}/3D_Dock/progs/"
pwd
make clean

################################################################################

cd "${SCRIPTDIR}/voronota/expansion_js"
rm -f "./voronota-js"

################################################################################

exit 0

