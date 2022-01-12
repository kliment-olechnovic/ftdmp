#!/bin/bash

cd "$(dirname $0)"
cd ..

export PATH="$HOME/git/voronota/expansion_js:$PATH"

if [ "$1" != "rescore" ]
then
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
	
	time -p (./ftdmp-dock-two-monomers \
	  --monomer1 ./test/output/monomers/6V3P_A.pdb \
	  --monomer2 ./test/output/monomers/6V3P_B.pdb \
	  --job-name 6V3P_rd_ \
	  --logs-output ./test/output/docking_results \
	  --parallel-parts 16 \
	  --ftdock-keep 1 \
	| column -t \
	> ./test/output/all_docking_results_table.txt)
fi


echo
echo "Scoring, sorting, filtering"

time -p (cat ./test/output/all_docking_results_table.txt \
| ./ftdmp-calc-interface-voromqa-scores \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --colnames-prefix DM_ \
  --adjoin \
| tee ./test/output/all_results_table.txt \
| ./ftdmp-sort-table \
  --columns "-DM_iface_energy" \
| head -501 \
| ./ftdmp-calc-interface-voromqa-scores \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --colnames-prefix DMsr_ \
  --parameters '--run-faspr ./core/FASPR/FASPR' \
  --adjoin \
| ./ftdmp-calc-interface-voromqa-scores \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
  --colnames-prefix BM_ \
  --parameters '--blanket' \
  --adjoin \
| ./ftdmp-calc-interface-voromqa-scores \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
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
| awk -v max_rank=100 '
NR==1 {for(i=1;i<=NF;i++){f[$i]=i}}
{
  if(NR==1 ||
     ($(f["DM_iface_energy_rank"])<=max_rank ||
      $(f["DMsr_iface_energy_rank"])<=max_rank ||
      $(f["BM_iface_energy_rank"])<=max_rank  ||
      $(f["BMsr_iface_energy_rank"])<=max_rank ||
      $(f["DM_tour_rank"])<=max_rank ||
      $(f["DMsr_tour_rank"])<=max_rank))
  {print $0}
}' \
| column -t \
| tee ./test/output/results_table.txt \
| awk '
NR==1 {for(i=1;i<=NF;i++){f[$i]=i}}
NR>1  {
  print $(f["ID"]),
        $(f["DM_iface_energy_rank"]),
        $(f["DMsr_iface_energy_rank"]),
        $(f["BM_iface_energy_rank"]),
        $(f["BMsr_iface_energy_rank"]),
        $(f["DM_tour_rank"]),
        $(f["DMsr_tour_rank"])
}' \
> ./test/output/ranks.txt)


echo
echo "Checking results with reference"

time -p (cat ./test/output/results_table.txt \
| ./ftdmp-calc-interface-cadscore-for-reference \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --reference ./test/reference_dimer/6V3P_AB.pdb \
  --parallel-parts 16 \
  --colnames-prefix CADS_ \
  --adjoin \
| ./ftdmp-sort-table \
  --columns "CADS_iface_cadscore" \
| column -t \
> ./test/output/reference_check_table.txt)


echo
echo "Calculating similarity matrix"

time -p (cat ./test/output/results_table.txt \
| ./ftdmp-calc-interface-cadscore-matrix \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --parallel-parts 16 \
> ./test/output/similarity_matrix.txt)


echo
echo "Calculating ranks jury scores"


./ftdmp-calc-ranks-jury-scores \
  --similarities ./test/output/similarity_matrix.txt \
  --ranks ./test/output/ranks.txt \
  --top-slices "25 50 75 100 99999" \
  --cluster 0.9 \
| column -t \
> ./test/output/jury_results.txt


echo
echo "Building top complexes"

rm -rf ./test/output/complexes

time -p (cat ./test/output/results_table.txt \
| ./ftdmp-build-complex \
  --monomer1 ./test/output/monomers/6V3P_A.pdb \
  --monomer2 ./test/output/monomers/6V3P_B.pdb \
  --output-prefix ./test/output/complexes/ \
> /dev/null)

#cat ./test/output/jury_results.txt | head -10 | awk '{print "./test/output/complexes/" $1 ".pdb"}' | xargs voronota-gl ./test/reference_dimer/6V3P_AB.pdb

