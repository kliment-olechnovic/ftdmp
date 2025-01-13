#!/bin/bash

cd "$(dirname $0)"

cd ../..
FTDMPDIR="$(pwd)"
cd - > /dev/null

CONDADIR="${HOME}/miniconda3"
CONDAENV="base"

STATICFILE="./input/5FS5_A.pdb"
MOBILEFILE="./input/5FS5_B.pdb"

JOBNAME="job1"

export GLOBAL_VORONOTA_JS_VOROMQA_BLANKET_TYPES_FILE="./input/custom_blanket_types_file"
export GLOBAL_VORONOTA_JS_INCLUDE_HETEROATOMS="true"

${FTDMPDIR}/ftdmp-all \
  --ftdmp-root "$FTDMPDIR" \
  --conda-path "$CONDADIR" \
  --conda-env "$CONDAENV" \
  --conda-early 'true' \
  --parallel-docking 20 \
  --parallel-scoring 20 \
  --job-name "$JOBNAME" \
  --output-dir "./output/docking" \
  --static-file "$STATICFILE" \
  --mobile-file "$MOBILEFILE" \
  --use-ftdock 'true' \
  --use-hex 'false' \
  --constraint-clashes 0.1 \
  --ftdock-keep 30 \
  --ftdock-angle-step 9 \
  --ftdock-min-grid-sep 10 \
  --scoring-rank-names 'generalized_voromqa' \
  --scoring-full-top 3000 \
  --scoring-ranks-top 200 \
  --scoring-jury-maxs 1 \
  --scoring-jury-slices '5 50' \
  --scoring-jury-cluster "$(seq 0.20 0.01 0.30)" \
  --redundancy-threshold 0.2 \
  --build-complexes 300 \
  --plot-jury-scores 'true' \
  --reference "./input/5FS5_reference.pdb" \
  --cache-dir "./output/docking/cache"

