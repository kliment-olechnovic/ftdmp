#!/bin/bash

cd "$(dirname $0)"

MAINMODE="$1"
JURYMAXS="$2"
JURYSLICES="$3"
PDBID="$4"

if [ -z "$MAINMODE" ] || [ -z "$PDBID" ]
then
	echo >&2 "Error: not two parameters provided"
	exit 1
fi

TFILE="${HOME}/git/voronota-iface-gnn/processes_v2/get_input_target_structures/output/${PDBID}.pdb"
MDIR="${HOME}/git/voronota-iface-gnn/processes_v2/redock_and_diversify/output/all/${PDBID}/raw_diverse_complexes/"

if [ ! -s "$TFILE" ] || [ ! -d "$MDIR" ]
then
	echo >&2 "Error: invalid PDB ID '$PDBID'"
	exit 1
fi

~/git/ftdmp/ftdmp-all --output-dir "./output/run_${MAINMODE}" --cache-dir ./cache \
  --job-name "$PDBID" --pre-docked-input-dir "$MDIR" --reference "$TFILE" \
  --conda-path "$HOME/anaconda3" --conda-env 'alphafold2' --conda-env-for-gnn 'gnncuda' --openmm-forcefield 'amber99sb' \
  --scoring-full-top 99999 --scoring-full-top-slow 99999 --scoring-ranks-top 99999 --plot-jury-scores "true" \
  --scoring-rank-names "$MAINMODE" \
  --scoring-jury-maxs "$JURYMAXS" \
  --scoring-jury-slices "$JURYSLICES"

