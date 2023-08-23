#!/bin/bash

cd "$(dirname $0)"

cd ../..
FTDMPDIR="$(pwd)"
cd - > /dev/null

CONDADIR="${HOME}/miniconda3"
CONDAENV="base"

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
  --scoring-rank-names 'file:custom_scoring_rank_names.txt' \
  --geom-hash-to-simplify 1 \
  --scoring-full-top 1000 \
  --scoring-full-top-slow 1000 \
  --scoring-ranks-top 100 \
  --scoring-jury-maxs 1 \
  --scoring-jury-slices '5 20' \
  --scoring-jury-cluster "$(seq 0.70 0.01 0.90)" \
  --redundancy-threshold 0.7 \
  --build-complexes 150 \
  --openmm-forcefield "amber99sb" \
  --relax-complexes "--max-iterations 0 --force-cuda --focus whole_interface" \
  --plot-jury-scores 'true' \
  --reference "./input/4UNG_reference.pdb" \
  --cache-dir "./output/cache"

