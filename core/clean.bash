#!/bin/bash

cd "$(dirname $0)"

pwd

cd "./fftw-2.1.3"
make clean
find ./ -type f -name 'Makefile' | xargs rm
rm "./config.log" "./config.status"

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

exit 0

