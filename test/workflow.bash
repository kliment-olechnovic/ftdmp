#!/bin/bash

export PATH="$HOME/git/voronota/expansion_js:$PATH"

rm -rf ./test/output

echo "Preparing monomers"

time -p ( \
./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/output/monomers/6V3P_A.pdb --restrict-input '[-chain A]' \
  --randomize --random-seed 999 --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2 \
; \
./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/output/monomers/6V3P_B.pdb --restrict-input '[-chain B]' \
  --randomize --random-seed 999 --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2 \
)


echo "Docking"

time -p (./ftdmp-dock \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --logs-output ./test/output/docking_results \
  --parallel-parts 16 \
| column -t \
> ./test/output/docking_table.txt)


echo "Scoring in default mode"

time -p (cat ./test/output/docking_table.txt \
| ./ftdmp-score \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --colnames-prefix DM_ \
| column -t \
> ./test/output/scoring_table.txt)

echo "Scoring in blanket mode"

time -p (cat ./test/output/docking_table.txt \
| ./ftdmp-score \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --colnames-prefix BM_ \
  --parameters '--blanket' \
| column -t \
> ./test/output/scoring_blanket_table.txt)


echo "Joining tables"

time -p (./ftdmp-join-tables \
  ./test/output/docking_table.txt \
  ./test/output/scoring_table.txt \
  ./test/output/scoring_blanket_table.txt \
| column -t \
> ./test/output/joined_results_table.txt)


echo "Sorting joined table"

time -p (cat ./test/output/joined_results_table.txt \
| ./ftdmp-sort-table \
  --columns "-DM_iface_energy -DM_iface_clash_score -BM_iface_energy" \
  --tolerances "0 0.07 30" \
| column -t \
> ./test/output/sorted_joined_results_table.txt)

cat ./test/output/sorted_joined_results_table.txt \
| head -101 \
> ./test/output/top_sorted_joined_results_table.txt


echo "Building top complexes"

time -p (cat ./test/output/top_sorted_joined_results_table.txt \
| ./ftdmp-build-complex \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  -o ./test/output/complexes/ \
> /dev/null)

