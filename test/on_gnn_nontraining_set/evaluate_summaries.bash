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
	
	r1=which(dt$raw_RJS_rank==1);
	
	subresult=data.frame(ID=input_table[i, 2]);
	subresult$top1_success=ifelse(dt$raw_FICS_iface_cadscore[r1]==max(dt$raw_FICS_iface_cadscore), 1, 0);
	subresult$top1_cs=dt$raw_FICS_iface_cadscore[r1];
	subresult$top1_F1=dt$raw_FICS_iface_F1[r1];
	subresult$top1_scs=dt$raw_FICS_iface_site_based_cadscore[r1];
	subresult$cor_w_cs=cor(dt$raw_RJS_max, dt$raw_FICS_iface_cadscore);
	subresult$cor_w_F1=cor(dt$raw_RJS_max, dt$raw_FICS_iface_F1);
	subresult$max_cs=max(dt$raw_FICS_iface_cadscore);
	subresult$max_scs=max(dt$raw_FICS_iface_site_based_cadscore);
	subresult$max_F1=max(dt$raw_FICS_iface_F1);
	
	if(is.element("raw_FIV_iface_area", colnames(dt))) {
		subresult$area_scs=dt$raw_FICS_iface_site_based_cadscore[order(0-dt$raw_FIV_iface_area)[1]];
	} else {
		subresult$area_scs=0;
	}
	
	if(is.element("raw_FIV_iface_energy_rank", colnames(dt))) {
		subresult$o_sum_scs=dt$raw_FICS_iface_site_based_cadscore[which(dt$raw_FIV_iface_energy_rank==1)];
	} else {
		subresult$o_sum_scs=0;
	}
	
	if(is.element("raw_FIGNN_sum_of_gnn_scores_rank", colnames(dt))) {
		subresult$gnn_sum_scs=dt$raw_FICS_iface_site_based_cadscore[which(dt$raw_FIGNN_sum_of_gnn_scores_rank==1)];
	} else {
		subresult$gnn_sum_scs=0;
	}
	
	if(is.element("raw_FIGNN_average_gnn_score_rank", colnames(dt))) {
		subresult$gnn_avg_scs=dt$raw_FICS_iface_site_based_cadscore[which(dt$raw_FIGNN_average_gnn_score_rank==1)];
	} else {
		subresult$gnn_avg_scs=0;
	}
	
	if(is.element("raw_FIV_and_FGV_dark_tour_rank", colnames(dt))) {
		subresult$o_tour_scs=dt$raw_FICS_iface_site_based_cadscore[which(dt$raw_FIV_and_FGV_dark_tour_rank==1)];
	} else {
		subresult$o_tour_scs=0;
	}
	
	if(is.element("raw_FIGNN_and_FGV_dark_tour_rank", colnames(dt))) {
		subresult$gnn_tour_scs=dt$raw_FICS_iface_site_based_cadscore[which(dt$raw_FIGNN_and_FGV_dark_tour_rank==1)];
	} else {
		subresult$gnn_tour_scs=0;
	}
	
	if(is.element("raw_FIV_iface_area", colnames(dt))) {
		subresult$area_cs=dt$raw_FICS_iface_cadscore[order(0-dt$raw_FIV_iface_area)[1]];
	} else {
		subresult$area_cs=0;
	}
	
	if(is.element("raw_FIV_iface_energy_rank", colnames(dt))) {
		subresult$o_sum_cs=dt$raw_FICS_iface_cadscore[which(dt$raw_FIV_iface_energy_rank==1)];
	} else {
		subresult$o_sum_cs=0;
	}
	
	if(is.element("raw_FIGNN_sum_of_gnn_scores_rank", colnames(dt))) {
		subresult$gnn_sum_cs=dt$raw_FICS_iface_cadscore[which(dt$raw_FIGNN_sum_of_gnn_scores_rank==1)];
	} else {
		subresult$gnn_sum_cs=0;
	}
	
	if(is.element("raw_FIGNN_average_gnn_score_rank", colnames(dt))) {
		subresult$gnn_avg_cs=dt$raw_FICS_iface_cadscore[which(dt$raw_FIGNN_average_gnn_score_rank==1)];
	} else {
		subresult$gnn_avg_cs=0;
	}
	
	if(is.element("raw_FIV_and_FGV_dark_tour_rank", colnames(dt))) {
		subresult$o_tour_cs=dt$raw_FICS_iface_cadscore[which(dt$raw_FIV_and_FGV_dark_tour_rank==1)];
	} else {
		subresult$o_tour_cs=0;
	}
	
	if(is.element("raw_FIGNN_and_FGV_dark_tour_rank", colnames(dt))) {
		subresult$gnn_tour_cs=dt$raw_FICS_iface_cadscore[which(dt$raw_FIGNN_and_FGV_dark_tour_rank==1)];
	} else {
		subresult$gnn_tour_cs=0;
	}
	
	if(length(result)==0){result=subresult;}else{result=rbind(result, subresult);}
}

result_summary=result[1,];
result_summary$ID="mean_of_all";

for(i in 2:ncol(result))
{
	result_summary[,i]=round(mean(result[,i]), digits=3);
}

result=rbind(result_summary, result);

write.table(result, file="output.txt", quote=FALSE, col.names=TRUE, row.names=FALSE, sep=" ");

EOF

cat "output.txt" | sed "s|^mean_of_all|${MODENAME}|" | column -t

