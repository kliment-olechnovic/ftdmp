#!/bin/bash

cd "$(dirname $0)"

cd ../..
FTDMPDIR="$(pwd)"
cd - > /dev/null

CONDADIR="${HOME}/anaconda3"
CONDAENV="alphafold2"

STATICFILE="./input/6FPQ_A.pdb"
MOBILEFILE="./input/6FPQ_B.pdb"

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
  --constraint-clashes 0.9 \
  --ftdock-keep 5 \
  --ftdock-angle-step 5 \
  --scoring-rank-names 'standard_for_generic' \
  --scoring-full-top 3000 \
  --scoring-ranks-top 200 \
  --scoring-jury-maxs 1 \
  --scoring-jury-slices '5 50' \
  --scoring-jury-cluster "$(seq 0.70 0.01 0.90)" \
  --redundancy-threshold 0.7 \
  --build-complexes 200 \
  --openmm-forcefield "amber14-all-no-water" \
  --relax-complexes "--max-iterations 0 --force-cuda --focus whole_interface" \
  --plot-jury-scores 'true' \
  --cache-dir "./output/docking/cache"

