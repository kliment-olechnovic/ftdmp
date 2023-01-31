#!/bin/bash

cd "$(dirname $0)"

cd ../..
FTDMPDIR="$(pwd)"
cd - > /dev/null

SCORING_CONDADIR="${HOME}/miniconda3"
SCORING_CONDAENV=""

OPENMM_CONDADIR="${HOME}/anaconda3"
OPENMM_CONDAENV="alphafold2"

STATICFILE="./input/4UNG_B.pdb"
MOBILEFILE="./input/4UNG_A.pdb"

rm -rf "./output/relaxing/relaxed_top_complexes"

for RSEED in 10 20 30
do
	JOBNAME="job_seed_${RSEED}"
	
	${FTDMPDIR}/ftdmp-all \
	  --ftdmp-root "$FTDMPDIR" \
	  --conda-path "$SCORING_CONDADIR" \
	  --conda-env "$SCORING_CONDAENV" \
	  --conda-early 'true' \
	  --parallel-docking 8 \
	  --parallel-scoring 8 \
	  --job-name "$JOBNAME" \
	  --output-dir "./output/docking" \
	  --static-file "$STATICFILE" \
	  --mobile-file "$MOBILEFILE" \
	  --mobile-rotation-seed "$RSEED" \
	  --use-ftdock 'true' \
	  --use-hex 'false' \
	  --constraint-clashes 0.9 \
	  --ftdock-keep 5 \
	  --ftdock-angle-step 9 \
	  --scoring-rank-names 'extended_for_protein_protein_no_sr' \
	  --scoring-full-top 1000 \
	  --scoring-full-top-slow 500 \
	  --scoring-ranks-top 100 \
	  --scoring-jury-maxs 1 \
	  --scoring-jury-slices '5 20' \
	  --scoring-jury-cluster "$(seq 0.70 0.01 0.90)" \
	  --redundancy-threshold 0.7 \
	  --build-complexes 20 \
	  --cache-dir "./output/docking/cache"

	find ./output/docking/${JOBNAME}/raw_top_complexes/ -type f -name '*.pdb' \
	| while read -r INFILE
	do
		OUTFILE="./output/relaxing/relaxed_top_complexes/$(basename ${INFILE})"
		
		${FTDMPDIR}/ftdmp-relax-with-openmm \
		  --conda-path "$OPENMM_CONDADIR" \
		  --conda-env "$OPENMM_CONDAENV" \
		  --force-cuda \
		  --full-preparation \
		  --forcefield "amber99sb" \
		  --input "$INFILE" \
		  --output "$OUTFILE" \
		  --cache-dir ./output/relaxing/cache
	done
done

find "./output/relaxing/relaxed_top_complexes/" -type f -name '*.pdb' \
| ${FTDMPDIR}/ftdmp-qa-all \
  --workdir "./output/qa" \
  --conda-path "$SCORING_CONDADIR" \
  --conda-env "$SCORING_CONDAENV" \
  --rank-names "protein_protein_voromqa_and_global_and_gnn_no_sr" \
  --jury-slices "5 20" \
  --jury-cluster "$(seq 0.70 0.01 0.90)" \
  --jury-maxs "1" \
  --output-redundancy-threshold "1" \
> "./output/qa_results.txt"

