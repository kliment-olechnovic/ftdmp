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

if [ ! -s "$TFILE" ]
then
	echo >&2 "Error: invalid PDB ID '$PDBID'"
	exit 1
fi

~/git/ftdmp/ftdmp-all \
  --output-dir "./output" \
  --cache-dir ./cache \
  --job-name "$PDBID" \
  --static-file "$TFILE" \
  --static-sel '[-chain A]' \
  --static-chain 'A' \
  --mobile-file "$TFILE" \
  --mobile-sel '[-chain B]' \
  --mobile-chain 'B' \
  --reference "$TFILE" \
  --conda-path "$HOME/anaconda3" \
  --conda-env 'alphafold2' \
  --conda-env-for-gnn 'gnncuda' \
  --openmm-forcefield 'amber99sb' \
  --scoring-full-top 1000 \
  --scoring-full-top-slow 300 \
  --scoring-ranks-top 100 \
  --plot-jury-scores "true" \
  --use-ftdock 'true' \
  --use-hex 'true' \
  --ftdock-keep 1 \
  --ftdock-angle-step 9 \
  --hex-max-solutions 6000 \
  --parallel-docking 8 \
  --parallel-scoring 8 \
  --scoring-rank-names "$MAINMODE" \
  --scoring-jury-maxs "$JURYMAXS" \
  --scoring-jury-slices "$JURYSLICES" \
  --build-complexes 300 \
  --relax-complexes '--max-iterations 0 --force-cuda --focus whole_interface --full-preparation'

