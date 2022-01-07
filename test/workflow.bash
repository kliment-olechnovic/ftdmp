#!/bin/bash

rm -rf ./test/monomers

./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/monomers/6V3P_A.pdb --restrict-input '[-chain A]' \
  --randomize --voronota-js-path ~/git/voronota/expansion_js \
  --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2

./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/monomers/6V3P_B.pdb --restrict-input '[-chain B]' \
  --randomize --voronota-js-path ~/git/voronota/expansion_js \
  --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2
  
rm -rf ./test/docking_results

./ftdmp-dock \
  -m1 ./test/monomers/6V3P_A.pdb \
  -m2 ./test/monomers/6V3P_B.pdb \
  --logs-output ./test/docking_results \
  --voronota-js-path ~/git/voronota/expansion_js \
  --parallel-parts 16 \
| column -t \
> ./test/docking_table.txt

cat ./test/docking_table.txt \
| ./ftdmp-score \
  -m1 ./test/monomers/6V3P_A.pdb \
  -m2 ./test/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --voronota-js-path ~/git/voronota/expansion_js \
| column -t \
> ./test/scoring_table.txt

rm -rf ./test/complexes

join <(sort -k 1b,1 ./test/docking_table.txt) <(head -6 ./test/scoring_table.txt | sort -k 1b,1) \
| ./ftdmp-build-complex \
  -m1 ./test/monomers/6V3P_A.pdb \
  -m2 ./test/monomers/6V3P_B.pdb \
  -o ./test/complexes/ \
  --voronota-js-path ~/git/voronota/expansion_js


