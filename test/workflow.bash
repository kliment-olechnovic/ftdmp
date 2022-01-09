#!/bin/bash

cd "$(dirname $0)"
cd ..

export PATH="$HOME/git/voronota/expansion_js:$PATH"

rm -rf ./test/output

echo
echo "Preparing monomers"

time -p ( \
./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/output/monomers/6V3P_A.pdb --restrict-input '[-chain A]' \
  --randomize --random-seed 1 --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2 \
; \
./ftdmp-prepare-monomer -i ./test/reference_dimer/6V3P_AB.pdb -o ./test/output/monomers/6V3P_B.pdb --restrict-input '[-chain B]' \
  --randomize --random-seed 2 --prepare-for-relax --conda-path ~/anaconda3 --conda-env alphafold2 \
)


echo
echo "Docking"

time -p (./ftdmp-dock \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --job-name 6V3P_rd_ \
  --logs-output ./test/output/docking_results \
  --parallel-parts 16 \
| column -t \
> ./test/output/all_docking_results_table.txt)


echo
echo "Scoring, sorting, filtering"

time -p (cat ./test/output/all_docking_results_table.txt \
| ./ftdmp-score-interface-voromqa \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --colnames-prefix DM_ \
  --adjoin \
| tee ./test/output/all_results_table.txt \
| ./ftdmp-sort-table \
  --columns "-DM_iface_energy" \
| head -301 \
| ./ftdmp-score-interface-voromqa \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --colnames-prefix DMsr_ \
  --parameters '--run-faspr ./core/FASPR/FASPR' \
  --adjoin \
| ./ftdmp-score-interface-voromqa \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --colnames-prefix BM_ \
  --parameters '--blanket' \
  --adjoin \
| ./ftdmp-score-interface-voromqa \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --colnames-prefix BMsr_ \
  --parameters '--blanket --run-faspr ./core/FASPR/FASPR' \
  --adjoin \
| ./ftdmp-sort-table \
  --columns "-DM_iface_energy" \
  --add-rank-column "DM_iface_energy_rank" \
| ./ftdmp-sort-table \
  --columns "-DMsr_iface_energy" \
  --add-rank-column "DMsr_iface_energy_rank" \
| ./ftdmp-sort-table \
  --columns "-BM_iface_energy" \
  --add-rank-column "BM_iface_energy_rank" \
| ./ftdmp-sort-table \
  --columns "-BMsr_iface_energy " \
  --add-rank-column "BMsr_iface_energy_rank" \
| ./ftdmp-sort-table \
  --columns "-DM_iface_energy -DM_iface_clash_score" \
  --tolerances "0 0.05" \
  --add-rank-column "DM_tour_rank" \
| ./ftdmp-sort-table \
  --columns "-DMsr_iface_energy -DMsr_iface_clash_score" \
  --tolerances "0 0.05" \
  --add-rank-column "DMsr_tour_rank" \
| ./ftdmp-sort-table \
  --columns "-DM_iface_energy -DM_iface_clash_score" \
  --tolerances "0 0.05" \
| column -t \
> ./test/output/results_table.txt)


echo
echo "Building top complexes"

time -p (cat ./test/output/results_table.txt \
| head -26 \
| ./ftdmp-build-complex \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  -o ./test/output/complexes/ \
> /dev/null)

echo


echo
echo "Checking results with reference"

time -p (cat ./test/output/results_table.txt \
| ./ftdmp-score-interface-cadscore \
  -m1 ./test/output/monomers/6V3P_A.pdb \
  -m2 ./test/output/monomers/6V3P_B.pdb \
  --reference ./test/reference_dimer/6V3P_AB.pdb \
  --parallel-parts 16 \
  --colnames-prefix CADS_ \
  --adjoin \
| ./ftdmp-sort-table \
  --columns "CADS_iface_cadscore" \
| column -t \
> ./test/output/reference_check_table.txt)

