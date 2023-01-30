#!/bin/bash

cd "$(dirname $0)"

pwd

cd -
cd "./fftw-2.1.5"
make clean
find ./ -type f -name 'Makefile' | xargs rm
rm "./config.log" "./config.status"

cd -
cd "./3D_Dock/progs/"
make clean

cd -
cd "./FASPR"
rm "./FASPR"

cd -
cd "./voronota-js_release"
rm "./voronota-js"

exit 0

