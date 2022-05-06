#!/bin/bash

SUMMARIES_DIR="$1"

if [ -z "$SUMMARIES_DIR" ] || [ ! -d "$SUMMARIES_DIR" ]
then
	echo >&2 "Error: invalid PDB ID '$PDBID'"
	exit 1
fi

MODENAME="$(basename ${SUMMARIES_DIR})"

readonly TMPLDIR=$(mktemp -d)
trap "rm -r $TMPLDIR" EXIT

find "$SUMMARIES_DIR" -type f -name '*.txt' -not -empty | sort > "${TMPLDIR}/input_files.txt"
cat "${TMPLDIR}/input_files.txt" | xargs -L 1 basename -s '.txt' > "${TMPLDIR}/input_basenames.txt"

paste "${TMPLDIR}/input_files.txt" "${TMPLDIR}/input_basenames.txt" | awk '{print $1 " " $2}' > "${TMPLDIR}/input_table.txt"

R --vanilla --args "${TMPLDIR}/input_table.txt" "${TMPLDIR}/results.txt" << 'EOF' > /dev/null
args=commandArgs(TRUE);
infile=args[1];
outfile=args[2];

result=c();

input_table=read.table(infile, header=FALSE, stringsAsFactors=FALSE);

for(i in 1:nrow(input_table))
{
	dt=read.table(input_table[i, 1], header=TRUE, stringsAsFactors=FALSE);
	
	subresult=data.frame(ID=input_table[i, 2]);
	subresult$top1_success=ifelse(dt$raw_FICS_iface_cadscore[1]==max(dt$raw_FICS_iface_cadscore), 1, 0);
	subresult$top1_cadscore=dt$raw_FICS_iface_cadscore[1];
	subresult$top1_F1=dt$raw_FICS_iface_F1[1];
	subresult$top1_site_cadscore=dt$raw_FICS_iface_site_based_cadscore[1];
	subresult$cor_with_cadscore=cor(dt$raw_RJS_max, dt$raw_FICS_iface_cadscore);
	subresult$cor_with_F1=cor(dt$raw_RJS_max, dt$raw_FICS_iface_F1);
	subresult$max_cadscore=max(dt$raw_FICS_iface_cadscore);
	subresult$max_site_cadscore=max(dt$raw_FICS_iface_site_based_cadscore);
	subresult$max_F1=max(dt$raw_FICS_iface_F1);
	
	if(length(result)==0){result=subresult;}else{result=rbind(result, subresult);}
}

result_summary=result[1,];
result_summary$ID="mean_of_all";

for(i in 2:ncol(result))
{
	result_summary[,i]=mean(result[,i]);
}

result=rbind(result_summary, result);

write.table(result, file="output.txt", quote=FALSE, col.names=TRUE, row.names=FALSE, sep=" ");

EOF

cat "output.txt" | sed "s|^mean_of_all|${MODENAME}|" | column -t

