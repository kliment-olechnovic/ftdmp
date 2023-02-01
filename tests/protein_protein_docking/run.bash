#!/bin/bash

cd "$(dirname $0)"

cd ../..
FTDMPDIR="$(pwd)"
cd - > /dev/null

CONDADIR="${HOME}/anaconda3"
CONDAENV="alphafold2"

STATICFILE="./input/4UNG_B.pdb"
MOBILEFILE="./input/4UNG_A.pdb"

JOBNAME="job1"

${FTDMPDIR}/ftdmp-all \
  --ftdmp-root "$FTDMPDIR" \
  --conda-path "$CONDADIR" \
  --conda-env "$CONDAENV" \
  --conda-early 'true' \
  --parallel-docking 8 \
  --parallel-scoring 8 \
  --job-name "$JOBNAME" \
  --output-dir "./output/docking" \
  --static-file "$STATICFILE" \
  --mobile-file "$MOBILEFILE" \
  --use-ftdock 'true' \
  --use-hex 'false' \
  --constraint-clashes 0.5 \
  --ftdock-keep 5 \
  --ftdock-angle-step 5 \
  --scoring-rank-names 'extended_for_protein_protein_no_sr' \
  --scoring-full-top 3000 \
  --scoring-full-top-slow 1500 \
  --scoring-ranks-top 100 \
  --scoring-jury-maxs 1 \
  --scoring-jury-slices '5 20' \
  --scoring-jury-cluster "$(seq 0.70 0.01 0.90)" \
  --redundancy-threshold 0.7 \
  --build-complexes 30 \
  --openmm-forcefield "amber99sb" \
  --relax-complexes "--max-iterations 0 --force-cuda --focus whole_interface" \
  --cache-dir "./output/cache"

