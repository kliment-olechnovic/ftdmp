#!/bin/bash

./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/monomers/6V3P_A.pdb --restrict-input '[-chain A]' \
  --randomize --voronota-js-path ~/git/voronota/expansion_js \
  --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2

./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/monomers/6V3P_B.pdb --restrict-input '[-chain B]' \
  --randomize --voronota-js-path ~/git/voronota/expansion_js \
  --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2

