#!/bin/bash

cd "$(dirname $0)"

PDBID="$1"
TFILE="${HOME}/git/voronota-iface-gnn/processes_v2/get_input_target_structures/output/${PDBID}.pdb"
MDIR="${HOME}/git/voronota-iface-gnn/processes_v2/redock_and_diversify/output/all/${PDBID}/raw_diverse_complexes/"

if [ -z "$PDBID" ] || [ ! -s "$TFILE" ] || [ ! -d "$MDIR" ]
then
	echo >&2 "Error: invalid PDB ID '$PDBID'"
	exit 1
fi

echo >&2 "Processing '$PDBID'"

for MAINMODE in extended_for_protein_protein standard_for_protein_protein extended_for_protein_protein_no_sr standard_for_protein_protein_no_sr
do
	for JURYSLICES in "1 30" "3 30"
	do
		for JURYMAXS in 1 3
		do
			./run_in_predefined_mode.bash "$MAINMODE" "$JURYMAXS" "$JURYSLICES" "$PDBID"
			
			SUMMARIESDIR="./output_summaries/${MAINMODE}__${JURYMAXS}__$(echo ${JURYSLICES} | tr ' ' '_')"
			mkdir -p "$SUMMARIESDIR"
			cp "./output/run_${MAINMODE}/${PDBID}/raw_top_scoring_results_RJS.txt" "${SUMMARIESDIR}/${PDBID}.txt"
		done
	done
done

