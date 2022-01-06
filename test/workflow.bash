#!/bin/bash

./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/monomers/6V3P_A --restrict-input '[-chain A]' \
  --randomize --voronota-js-path ~/git/voronota/expansion_js \
  --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2

./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/monomers/6V3P_B --restrict-input '[-chain B]' \
  --randomize --voronota-js-path ~/git/voronota/expansion_js \
  --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2
  
rm -rf ./test/docking_results

./ftdmp-dock \
  -i1 ./test/monomers/6V3P_A__full.pdb \
  -i2 ./test/monomers/6V3P_B__full.pdb \
  --logs-output ./test/docking_results \
  --voronota-js-path ~/git/voronota/expansion_js \
  --parallel-parts 16 \
| wc -l

