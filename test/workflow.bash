#!/bin/bash

export PATH="$HOME/git/voronota/expansion_js:$PATH"

rm -rf ./test/output

./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/output/monomers/6V3P_A.pdb --restrict-input '[-chain A]' \
  --randomize --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2

./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/output/monomers/6V3P_B.pdb --restrict-input '[-chain B]' \
  --randomize --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2
  
rm -rf ./test/output/docking_results

./ftdmp-dock \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --logs-output ./test/output/docking_results \
  --parallel-parts 16 \
| column -t \
> ./test/output/docking_table.txt

cat ./test/output/docking_table.txt \
| ./ftdmp-score \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
| column -t \
> ./test/output/scoring_table.txt

rm -rf ./test/complexes

join <(sort -k 1b,1 ./test/output/docking_table.txt) <(head -6 ./test/output/scoring_table.txt | sort -k 1b,1) \
| ./ftdmp-build-complex \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  -o ./test/complexes/


