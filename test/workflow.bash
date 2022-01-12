#!/bin/bash

cd "$(dirname $0)"
cd ..

export PATH="$HOME/git/voronota/expansion_js:$PATH"

rm -rf ./test/output
	
./ftdmp-prepare-monomer --input ./test/reference_dimer/6V3P_AB.pdb --output ./test/output/monomers/6V3P_A.pdb --restrict-input '[-chain A]' \
  --randomize --random-seed 1 --forcefield amber99sb --conda-path ~/anaconda3 --conda-env alphafold2

./ftdmp-prepare-monomer --input ./test/reference_dimer/6V3P_AB.pdb --output ./test/output/monomers/6V3P_B.pdb --restrict-input '[-chain B]' \
  --randomize --random-seed 2 --forcefield amber99sb --conda-path ~/anaconda3 --conda-env alphafold2

./ftdmp-dock-two-monomers \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --job-name 6V3P_rd_ \
  --logs-output ./test/output/docking_results \
  --parallel 16 \
  --ftdock-keep 1 \
| column -t \
| tee ./test/output/all_docking_results_table.txt \
| ./ftdmp-calc-interface-voromqa-scores \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --parallel 16 \
  --colnames-prefix FIV_ \
  --adjoin \
| tee ./test/output/all_results_table.txt \
| ./ftdmp-sort-table \
  --columns "-FIV_iface_energy" \
| head -501 \
| ./ftdmp-calc-interface-voromqa-scores \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --parallel 16 \
  --rebuild-sidechains \
  --colnames-prefix FIVsr_ \
  --adjoin \
| ./ftdmp-calc-interface-voromqa-scores \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --parallel 16 \
  --blanket \
  --colnames-prefix bFIV_ \
  --adjoin \
| ./ftdmp-calc-interface-voromqa-scores \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --parallel 16 \
  --rebuild-sidechains \
  --blanket \
  --colnames-prefix bFIVsr_ \
  --adjoin \
| ./ftdmp-sort-table \
  --columns "-FIV_iface_energy" \
  --add-rank-column "FIV_iface_energy_rank" \
| ./ftdmp-sort-table \
  --columns "-FIVsr_iface_energy" \
  --add-rank-column "FIVsr_iface_energy_rank" \
| ./ftdmp-sort-table \
  --columns "-bFIV_iface_energy" \
  --add-rank-column "bFIV_iface_energy_rank" \
| ./ftdmp-sort-table \
  --columns "-bFIVsr_iface_energy " \
  --add-rank-column "bFIVsr_iface_energy_rank" \
| ./ftdmp-sort-table \
  --columns "-FIV_iface_energy -FIV_iface_clash_score" \
  --tolerances "0 0.05" \
  --add-rank-column "FIV_tour_rank" \
| ./ftdmp-sort-table \
  --columns "-FIVsr_iface_energy -FIVsr_iface_clash_score" \
  --tolerances "0 0.05" \
  --add-rank-column "FIVsr_tour_rank" \
| ./ftdmp-filter-table \
  '<=50'  FIV_iface_energy_rank  FIVsr_iface_energy_rank  bFIV_iface_energy_rank  bFIVsr_iface_energy_rank  FIV_tour_rank  FIVsr_tour_rank \
| ./ftdmp-calc-interface-cadscore-matrix \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --matrix-output "./test/output/similarity_matrix.txt" \
  --parallel 16 \
| ./ftdmp-calc-ranks-jury-scores \
  --similarities ./test/output/similarity_matrix.txt \
  --rank-columns "FIV_iface_energy_rank  FIVsr_iface_energy_rank  bFIV_iface_energy_rank  bFIVsr_iface_energy_rank  FIV_tour_rank  FIVsr_tour_rank" \
  --top-slices "25 50 75 100 99999" \
  --cluster 0.9 \
  --colnames-prefix RJS_ \
  --adjoin \
| ./ftdmp-calc-interface-cadscore-for-reference \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --reference ./test/reference_dimer/6V3P_AB.pdb \
  --parallel 16 \
  --colnames-prefix CADS_ \
  --adjoin \
| ./ftdmp-sort-table \
  --columns "-RJS_rank" \
| column -t \
| tee ./test/output/results_table.txt \
| ./ftdmp-build-complex \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --output-prefix ./test/output/complexes/ \
| wc -l

#cat ./test/output/results_table.txt | awk 'NR>1 {print $1}' | head -10 | awk '{print "./test/output/complexes/" $1 ".pdb"}' | xargs voronota-gl ./test/reference_dimer/6V3P_AB.pdb

