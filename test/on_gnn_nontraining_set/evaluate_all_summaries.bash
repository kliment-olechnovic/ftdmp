#!/bin/bash

cd "$(dirname $0)"

mkdir -p "./output_summaries_evaluation"

find ./output_summaries/ -mindepth 1 -maxdepth 1 -type d \
| sort \
| while read -r SUMMARIES_DIR
do
	./evaluate_summaries.bash "$SUMMARIES_DIR" > "./output_summaries_evaluation/all__$(basename ${SUMMARIES_DIR}).txt"
done


find ./output_summaries_evaluation/ -type f -name 'all__*.txt' \
| sort \
| xargs -L 1 head -2 \
| awk '{if(NR==1 || $1!="ID"){print $0}}' \
| column -t \
> "./output_summaries_evaluation/global_results.txt"

cd "./output_summaries_evaluation"

R --vanilla << 'EOF' > /dev/null
dt=read.table("global_results.txt", header=TRUE, stringsAsFactors=FALSE);
dt=dt[order(0-dt$top1_cadscore, 0-dt$top1_F1),];
write.table(dt, file="global_results.txt", quote=FALSE, col.names=TRUE, row.names=FALSE, sep=" ");
EOF

cat "global_results.txt" | column -t | sponge "global_results.txt"

cat "global_results.txt"
