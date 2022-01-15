#!/bin/bash

cd "$(dirname $0)"
cd ..

################################################################################

OUTPUT_PATH="./test/output"
JOB_NAME="6V3P_rd"
STATIC_STRUCTURE_FILE="./test/reference_dimer/6V3P_AB.pdb"
STATIC_STRUCTURE_SELECTION="[-chain A]"
STATIC_STRUCTURE_NAME="6V3P_A"
MOBILE_STRUCTURE_FILE="./test/reference_dimer/6V3P_AB.pdb"
MOBILE_STRUCTURE_SELECTION="[-chain B]"
MOBILE_STRUCTURE_NAME="6V3P_B"
REFERENCE_STRUCTURE_FILE_FOR_COMPARISON="./test/reference_dimer/6V3P_AB.pdb"
CONDA_PATH="$HOME/anaconda3"
CONDA_ENV="alphafold2"
VORONOTA_JS_PATH="$HOME/git/voronota/expansion_js"

OPENMM_FORCEFIELD="amber99sb"
FTDOCK_KEEP="1"
FTDOCK_ANGLE_STEP="9"
DOCKING_PROCESSORS=16
SCORING_PROCESSORS=16
SCORING_TOP_STAGE1=500
SCORING_TOP_STAGE2=50
SCORING_MODE_PROTEIN="true"
SCORING_MODE_PROTEIN_SIDECHAIN_REBUILT="true"
SCORING_MODE_GENERIC="true"
SCORING_MODE_GENERIC_SIDECHAIN_REBUILT="true"
SCORING_REBUILD_SIDECHAINS="true"
SCORING_RANKS=""
SCORING_RANKS_JURY_SLICES="25 50 75 100 99999"
NUMBER_OF_COMPLEXES_TO_BUILD=10

################################################################################

if [ -z "$SCORING_RANKS" ]
then
	if [ "$SCORING_MODE_PROTEIN" == "true" ]
	then
		SCORING_RANKS="$SCORING_RANKS  FIV_iface_energy_rank  FIV_iface_energy_norm_rank FIV_energy_clash_tour_rank  FIV_energy_norm_clash_tour_rank"
	fi
	
	if [ "$SCORING_MODE_PROTEIN_SIDECHAIN_REBUILT" == "true" ]
	then
		SCORING_RANKS="$SCORING_RANKS  FIV_sr_iface_energy_rank  FIV_sr_iface_energy_norm_rank  FIV_sr_energy_clash_tour_rank  FIV_sr_energy_norm_clash_tour_rank"
	fi
	
	if [ "$SCORING_MODE_GENERIC" == "true" ]
	then
		SCORING_RANKS="$SCORING_RANKS  FIVb_iface_energy_rank  FIVb_iface_energy_norm_rank  FIVb_energy_clash_tour_rank  FIVb_energy_norm_clash_tour_rank"
	fi
	
	if [ "$SCORING_MODE_GENERIC_SIDECHAIN_REBUILT" == "true" ]
	then
		SCORING_RANKS="$SCORING_RANKS  FIVb_sr_iface_energy_rank  FIVb_sr_iface_energy_norm_rank  FIVb_sr_energy_clash_tour_rank  FIVb_sr_energy_norm_clash_tour_rank"
	fi
fi

export PATH="${VORONOTA_JS_PATH}:${PATH}"

OUTPUT_PATH="${OUTPUT_PATH}/${JOB_NAME}"
mkdir -p "$OUTPUT_PATH"

PREPARED_STATIC_STRUCTURE_FILE="${OUTPUT_PATH}/monomers/${STATIC_STRUCTURE_NAME}.pdb"

./ftdmp-prepare-monomer --input "$STATIC_STRUCTURE_FILE" --output "$PREPARED_STATIC_STRUCTURE_FILE" --restrict-input "$STATIC_STRUCTURE_SELECTION" \
  --randomize --random-seed 1 --forcefield "$OPENMM_FORCEFIELD" --conda-path "$CONDA_PATH" --conda-env "$CONDA_ENV"

PREPARED_MOBILE_STRUCTURE_FILE="${OUTPUT_PATH}/monomers/${MOBILE_STRUCTURE_NAME}.pdb"

./ftdmp-prepare-monomer --input "$MOBILE_STRUCTURE_FILE" --output "$PREPARED_MOBILE_STRUCTURE_FILE" --restrict-input "$MOBILE_STRUCTURE_SELECTION" \
  --randomize --random-seed 1 --forcefield "$OPENMM_FORCEFIELD" --conda-path "$CONDA_PATH" --conda-env "$CONDA_ENV"

DOCKING_RESULTS_FILE="${OUTPUT_PATH}/docking_results.txt"

if [ ! -s "$DOCKING_RESULTS_FILE" ]
then
	./ftdmp-dock-two-monomers --monomer1 "$PREPARED_STATIC_STRUCTURE_FILE" --monomer2 "$PREPARED_MOBILE_STRUCTURE_FILE" \
	  --job-name "${JOB_NAME}_" \
	  --parallel "$DOCKING_PROCESSORS" \
	  --ftdock-keep "$FTDOCK_KEEP" \
	  --ftdock-angle-step "$FTDOCK_ANGLE_STEP" \
	> "$DOCKING_RESULTS_FILE"
fi

SCORING_RESULTS_FILE="${OUTPUT_PATH}/scoring_results.txt"

cat "$DOCKING_RESULTS_FILE" \
| {
	if [ "$SCORING_MODE_PROTEIN" == "true" ]
	then
		./ftdmp-calc-interface-voromqa-scores --monomer1 "$PREPARED_STATIC_STRUCTURE_FILE" --monomer2 "$PREPARED_MOBILE_STRUCTURE_FILE" \
		  --parallel "$SCORING_PROCESSORS" \
		  --colnames-prefix FIV_ \
		  --adjoin \
		| tee "${OUTPUT_PATH}/scoring_results_FIV.txt" \
		| ./ftdmp-sort-table --columns "-FIV_iface_energy" \
		| head -n "$((SCORING_TOP_STAGE1+1))"
	else
		cat
	fi
} \
| {
	if [ "$SCORING_MODE_GENERIC" == "true" ]
	then
		./ftdmp-calc-interface-voromqa-scores --monomer1 "$PREPARED_STATIC_STRUCTURE_FILE" --monomer2 "$PREPARED_MOBILE_STRUCTURE_FILE" \
		  --parallel "$SCORING_PROCESSORS" \
		  --blanket \
		  --colnames-prefix FIVb_ \
		  --adjoin \
		| tee "${OUTPUT_PATH}/scoring_results_FIVb.txt" \
		| ./ftdmp-sort-table --columns "-FIVb_iface_energy" \
		| head -n "$((SCORING_TOP_STAGE1+1))"
	else
		cat
	fi
} \
| {
	if [ "$SCORING_MODE_PROTEIN_SIDECHAIN_REBUILT" == "true" ]
	then
		./ftdmp-calc-interface-voromqa-scores --monomer1 "$PREPARED_STATIC_STRUCTURE_FILE" --monomer2 "$PREPARED_MOBILE_STRUCTURE_FILE" \
		  --parallel "$SCORING_PROCESSORS" \
		  --rebuild-sidechains \
		  --colnames-prefix FIV_sr_ \
		  --adjoin \
		| tee "${OUTPUT_PATH}/scoring_results_FIV_sr.txt" \
		| ./ftdmp-sort-table --columns "-FIV_sr_iface_energy" \
		| head -n "$((SCORING_TOP_STAGE1+1))"
	else
		cat
	fi
} \
| {
	if [ "$SCORING_MODE_GENERIC_SIDECHAIN_REBUILT" == "true" ]
	then
		./ftdmp-calc-interface-voromqa-scores --monomer1 "$PREPARED_STATIC_STRUCTURE_FILE" --monomer2 "$PREPARED_MOBILE_STRUCTURE_FILE" \
		  --parallel "$SCORING_PROCESSORS" \
		  --blanket --rebuild-sidechains \
		  --colnames-prefix FIVb_sr_ \
		  --adjoin \
		| tee "${OUTPUT_PATH}/scoring_results_FIVb_sr.txt" \
		| ./ftdmp-sort-table --columns "-FIVb_sr_iface_energy" \
		| head -n "$((SCORING_TOP_STAGE1+1))"
	else
		cat
	fi
} \
| {
	if [ "$SCORING_MODE_PROTEIN" == "true" ]
	then
		./ftdmp-sort-table \
		  --columns "-FIV_iface_energy" \
		  --add-rank-column "FIV_iface_energy_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIV_iface_energy_norm" \
		  --add-rank-column "FIV_iface_energy_norm_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIV_iface_energy -FIV_iface_clash_score" \
		  --tolerances "0 0.05" \
		  --add-rank-column "FIV_energy_clash_tour_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIV_iface_energy -FIV_iface_energy_norm -FIV_iface_clash_score" \
		  --tolerances "0 0 0.05" \
		  --add-rank-column "FIV_energy_norm_clash_tour_rank"
	else
		cat
	fi
} \
| {
	if [ "$SCORING_MODE_GENERIC" == "true" ]
	then
		./ftdmp-sort-table \
		  --columns "-FIVb_iface_energy" \
		  --add-rank-column "FIVb_iface_energy_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIVb_iface_energy_norm" \
		  --add-rank-column "FIVb_iface_energy_norm_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIVb_iface_energy -FIVb_iface_clash_score" \
		  --tolerances "0 0.05" \
		  --add-rank-column "FIVb_energy_clash_tour_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIVb_iface_energy -FIVb_iface_energy_norm -FIVb_iface_clash_score" \
		  --tolerances "0 0 0.05" \
		  --add-rank-column "FIVb_energy_norm_clash_tour_rank"
	else
		cat
	fi
} \
| {
	if [ "$SCORING_MODE_PROTEIN_SIDECHAIN_REBUILT" == "true" ]
	then
		./ftdmp-sort-table \
		  --columns "-FIV_sr_iface_energy" \
		  --add-rank-column "FIV_sr_iface_energy_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIV_sr_iface_energy_norm" \
		  --add-rank-column "FIV_sr_iface_energy_norm_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIV_sr_iface_energy -FIV_sr_iface_clash_score" \
		  --tolerances "0 0.05" \
		  --add-rank-column "FIV_sr_energy_clash_tour_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIV_sr_iface_energy -FIV_sr_iface_energy_norm -FIV_sr_iface_clash_score" \
		  --tolerances "0 0 0.05" \
		  --add-rank-column "FIV_sr_energy_norm_clash_tour_rank"
	else
		cat
	fi
} \
| {
	if [ "$SCORING_MODE_GENERIC_SIDECHAIN_REBUILT" == "true" ]
	then
		./ftdmp-sort-table \
		  --columns "-FIVb_sr_iface_energy" \
		  --add-rank-column "FIVb_sr_iface_energy_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIVb_sr_iface_energy_norm" \
		  --add-rank-column "FIVb_sr_iface_energy_norm_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIVb_sr_iface_energy -FIVb_sr_iface_clash_score" \
		  --tolerances "0 0.05" \
		  --add-rank-column "FIVb_sr_energy_clash_tour_rank" \
		| ./ftdmp-sort-table \
		  --columns "-FIVb_sr_iface_energy -FIVb_sr_iface_energy_norm -FIVb_sr_iface_clash_score" \
		  --tolerances "0 0 0.05" \
		  --add-rank-column "FIVb_sr_energy_norm_clash_tour_rank"
	else
		cat
	fi
} \
> "$SCORING_RESULTS_FILE"

TOP_SCORING_RESULTS_FILE="${OUTPUT_PATH}/top_scoring_results.txt"

cat "$SCORING_RESULTS_FILE" \
| ./ftdmp-filter-table \
  "<=${SCORING_TOP_STAGE2}" $SCORING_RANKS \
| ./ftdmp-calc-interface-cadscore-matrix --monomer1 "$PREPARED_STATIC_STRUCTURE_FILE" --monomer2 "$PREPARED_MOBILE_STRUCTURE_FILE" \
  --matrix-output "${OUTPUT_PATH}/similarity_matrix.txt" \
  --parallel "$SCORING_PROCESSORS" \
| ./ftdmp-calc-ranks-jury-scores \
  --similarities "${OUTPUT_PATH}/similarity_matrix.txt" \
  --rank-columns "$SCORING_RANKS" \
  --top-slices "$SCORING_RANKS_JURY_SLICES" \
  --cluster 0.9 \
  --colnames-prefix RJS_ \
  --adjoin \
| {
	if [ -n "$REFERENCE_STRUCTURE_FILE_FOR_COMPARISON" ]
	then
		./ftdmp-calc-interface-cadscore-for-reference --monomer1 "$PREPARED_STATIC_STRUCTURE_FILE" --monomer2 "$PREPARED_MOBILE_STRUCTURE_FILE" \
		  --reference "$REFERENCE_STRUCTURE_FILE_FOR_COMPARISON" \
		  --parallel "$SCORING_PROCESSORS" \
		  --colnames-prefix FCADS_ \
		  --adjoin
	else
		cat
	fi
} \
| ./ftdmp-calc-interface-cadscore-for-reference --monomer1 "$PREPARED_STATIC_STRUCTURE_FILE" --monomer2 "$PREPARED_MOBILE_STRUCTURE_FILE" \
  --reference ./test/reference_dimer/6V3P_AB.pdb \
  --parallel "$SCORING_PROCESSORS" \
  --colnames-prefix FCADS_ \
  --adjoin \
| ./ftdmp-sort-table \
  --columns "-RJS_rank" \
| column -t \
> "$TOP_SCORING_RESULTS_FILE"

if [ "$NUMBER_OF_COMPLEXES_TO_BUILD" -gt "0" ]
then
	cat "$TOP_SCORING_RESULTS_FILE" \
	| head -n "$((NUMBER_OF_COMPLEXES_TO_BUILD+1))" \
	| ./ftdmp-build-complex --monomer1 "$PREPARED_STATIC_STRUCTURE_FILE" --monomer2 "$PREPARED_MOBILE_STRUCTURE_FILE" \
	  --output-prefix "${OUTPUT_PATH}/top_complexes/" \
	  --output-suffix ".pdb" \
	| tail -n +2 \
	| awk -v prefix="${OUTPUT_PATH}/top_complexes/" -v suffix=".pdb" '{print prefix $1 suffix}' \
	> "${OUTPUT_PATH}/top_complexes_ordered_list.txt"
fi

