#!/bin/bash

#####   NOME:            freddie.sh
#####   DESCRIÇÃO:       Identifica transcritos quiméricos e seus dominios adicionados (2ª Versão). Corrigindo os transcritos noncoding, redu$
#####   DATA DA CRIAÇÃO: 19/07/2020
#####   ESCRITO POR:     Rafael L. V. Mercuri
#####   E-MAIL:          rmercuri@mochsl.org.br
#####	Dependências: Stringtie2, gffread, python3 (Bio), Docker, Hammer, kallisto, R(ggplot2 e reshape2)

string(){
	echo 'Running Stringtie'
	for i in $(ls input/*.bam | awk -F'/' '{print $NF}')
	do
		stringtie input/$i -G ann/gencode.v32.annotation.gtf -p 8 -o output_str/$i.gtf
	done

	echo 'Joining gtfs'
	stringtie --merge -p 8 -G ann/gencode.v32.annotation.gtf -o output/$prefix.merge.gtf output_str/*.gtf
}

chimeric(){
	echo 'Finding new transcripts'

	#Dicionário de protein codings
	grep -w gene ann/gencode.v32.annotation.gtf | grep -w protein_coding| awk -F'"' '{print $2}' | \
	sed 's/\.[0-9][0-9]//g' | sed 's/\.[0-9]//g' > coding.tmp
	grep -f coding.tmp output/$prefix.merge.gtf | awk -F'"' '{print $2}' | sort -u | sed 's/\./\\./g' > dic.tmp

	#Filtro de transcritos anotados
	grep -v "gene_name" output/$prefix.merge.gtf > output/$prefix.novels.gtf

	#Criando um bed com todos os transcritos ja anotados de protein_coding
	grep -w 'transcript_type "protein_coding"' ann/gencode.v32.annotation.gtf | grep -w exon | cut -f 1,4,5,9 > tmp/gencode.exon.bed

	#Pegando os exons dos novos transcritos
	grep -w exon output/$prefix.novels.gtf| awk -F "\t" '{print $1"\t"$4"\t"$5"\t"$9}' > $prefix.tmp

	#Lista dos transcritos novos que tem RTC
	echo 'Finding chimeric transcripts'
	bedtools intersect -f 0.5 -wo -a $input -b $prefix.tmp | cut -f 8| awk -F'"' '{print $4"\t"$6}'|\
	 sort -u| sed 's/\./\\./g' > output/$prefix.chimeric.txt

	#Montando um gtf dos transcritos novos anotados pelo stringtie
	grep -w -f <(cut -f 1 output/$prefix.chimeric.txt) output/$prefix.merge.gtf > output/$prefix.protein.gtf

	#Montando um gtf e um bed com possiveis transcritos quiméricos
	grep -w -f dic.tmp output/$prefix.protein.gtf > tmp/$prefix.chimeric.tmp.gtf
	grep -w exon tmp/$prefix.chimeric.tmp.gtf | cut -f 1,4,5,9 > tmp/$prefix.exon.bed
	bedtools intersect -wo -a tmp/$prefix.exon.bed -b tmp/gencode.exon.bed | cut -f 4,8 | \
	awk -F '"' '{print $4"\t"$8"\t"$10}' | sort | uniq -c | sort -k2,2 -k1,1r > tmp/$prefix.partial.tsv
	for i in $(awk -F " " '{if ($1 > 1) print $2}' tmp/$prefix.partial.tsv | sort -u);do
		fgrep ${i} tmp/$prefix.partial.tsv | head -n1 | cut -f 1 | \
		fgrep -wf - tmp/$prefix.partial.tsv | awk -F" " '{print $2"\t"$3"\t"$4}' >> output/$prefix.most_shared.tsv
	done

	grep -w -f <(cut -f 1 output/$prefix.most_shared.tsv| sort -u) output/$prefix.protein.gtf > output/$prefix.chimeric.gtf

	#Classificando internal initial e final
	python3 scripts/bed_novel.py output/$prefix.chimeric.gtf > tmp/$prefix.info.tmp
	sed 's/\\//g' output/$prefix.chimeric.txt > tmp/$prefix.joined.txt
	join <(sort -k1,1 -k2,2n tmp/$prefix.info.tmp) <(sort -k1,1 -k2,2n tmp/$prefix.joined.txt) | \
	awk -F " " '{if ($3 == $4 && $2 == "+") print $1"\t"$2"\t"$3"\t"$4"\tNovel Final"; else if ($3 == $4 && $2 == "-") print $1"\t"$2"\t"$3"\t"$4"\tNovel Initial"; else if ($4 == 1 && $2 == "+") print $1"\t"$2"\t"$3"\t"$4"\tNovel Initial"; else if ($4 == 1 && $2 == "-") print $1"\t"$2"\t"$3"\t"$4"\tNovel Final"; else print $1"\t"$2"\t"$3"\t"$4"\tNovel Internal"}' > tmp/$prefix.info.tsv
	grep -v -f <(cut -f 1 tmp/$prefix.info.tsv | uniq -c | awk '{if ($1 > 1) print $2}') tmp/$prefix.info.tsv > output/$prefix.info.tsv

	#Arquivo fasta dos possiveis transcritos quimericos do stringtie
	gffread output/$prefix.chimeric.gtf -g ann/hg38.fa -w ann/$prefix.chimeric.fasta

	rm output/$prefix.novels.gtf
	rm output/$prefix.chimeric.txt
	rm *.tmp
	rm tmp/*
	rm output/$prefix.protein.gtf
}

coding(){
	#Rodar o RNASamba
	echo "Running RNASamba"
	docker run -ti --rm -v $abs/ann/:/app antoniopcamargo/rnasamba classify -p $prefix.predicted_proteins.fa $prefix.classification.tsv $prefix.chimeric.fasta human38_model.hdf5
	#Movendo os resultados do RNASamba para o output
	mv ann/$prefix.* output/
	#Selecionando somente os transcritos dos protein_coding com protencial codificante
	echo "Done!"
	echo "Selecting chimeric transcripts with coding potential"
	awk '{if ($3 > 0.9) print $1}' output/$prefix.classification.tsv | awk -F'.' '{print $1"\\."$2}' | sed 1d > gene.txt
	grep -w -f gene.txt output/$prefix.merge.gtf | grep -w -v exon | grep gene_name | awk -F'"' '{print $2"\t"$8}' | sort -u | sed 's/\.[0-9][0-9]$//g' | sed 's/\.[0-9]$//g' > $prefix.coding.txt
	awk '{if ($3 > 0.9) print $1}' output/$prefix.classification.tsv | sed 1d | awk -F'.' '{print $1"."$2"\t"$1"."$2"."$3}'> transcript.txt
	#Selecionando a sequencia de AA dos respectivos.
	python3 scripts/select_fasta.py <(cut -f 2 transcript.txt) output/$prefix.predicted_proteins.fa output/$prefix.MSTRG_blacklist > output/$prefix.novel_proteins.fa
	python3 scripts/select_fasta.py <(cut -f 2 $prefix.coding.txt) ann/Homo_sapiens.GRCh38.pep.all.fa  output/$prefix.ENSG_blacklist > output/$prefix.ann_proteins.fa
	rm gene.txt
}

pfam(){
	echo "Running PFAM..."
	cat output/$prefix.novel_proteins.fa output/$prefix.ann_proteins.fa > tmp/pfam.test.tmp
	hmmsearch --tblout tmp/pfam.hmm.test -E 1e-6 --cpu 4 ann/Pfam-A.hmm tmp/pfam.test.tmp > log 2> log.err
	echo "Done"

	echo "Comparing chimeric domains with host domains"
	awk '{if ($3 < 3) print}' output/$prefix.info.tsv | cut -f 1 | sed 's/\./\\./g' | sort -u >> output/$prefix.MSTRG_blacklist

	join <(sort transcript.txt) <(sort $prefix.coding.txt)| sed 's/ /\t/g' | sed 's/\./\\./g' > tmp/$prefix.join.tmp.txt
	grep -v -f output/$prefix.MSTRG_blacklist <(sed 's/\\./\./g' tmp/$prefix.join.tmp.txt) | grep -v -f output/$prefix.ENSG_blacklist|\
	sed 's/\./\\./g' > tmp/$prefix.join.txt

	while read gene trans host
	do
		grep -w $trans tmp/pfam.hmm.test > tmp/$trans.$host.txt
		grep -w $host tmp/pfam.hmm.test >> tmp/$trans.$host.txt
		grep -v \# tmp/$trans.$host.txt | awk -F" " '{print $1,$3,$6,$4}' > tmp/pfam.tmp
		python3 scripts/comp_dom.py tmp/pfam.tmp $trans > tmp/$trans.$host.pfam.tsv
	done < tmp/$prefix.join.txt

        for i in $(cut -f 2 transcript.txt)
        do
                cat tmp/$i.*.pfam.tsv | grep -v \# > tmp/$i.tmp.pfam.tsv
                python3 scripts/arr_dom.py tmp/$i.tmp.pfam.tsv > tmp/$i.pfamf.tsv
        done

	cat tmp/*.pfamf.tsv > output/$prefix.info_dom.tsv
	echo "Done"

	rm tmp/*
	rm $prefix.coding.txt
	rm transcript.txt
}

expression(){
        #1 Passo criar um arquivo com os fasta.gz do projeto
        echo 'Creating a FASTA File ...'
        gffread output/$prefix.merge.gtf -g ann/hg38.fa -w tmp/$prefix.merge.fa
        cd tmp/
        gzip ${prefix}.merge.fa
        cd ..
        mkdir output/${prefix}

        #2 Passo criar um index para o Kallisto
        echo 'Running Kallisto index ...'
        kallisto index -i output/${prefix}/${prefix}.transcripts.idx \
                tmp/${prefix}.merge.fa.gz \
                2> tmp/${prefix}.index.log

        #3 Passo quantificar por amostra
        echo 'Running Kallisto Quant ...'
        for sample in $(ls input/*p1.fq.gz | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}')
        do
                mkdir output/${prefix}/${sample}
        done

        for sample in $(ls input/*p1.fq.gz | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}')
        do
                echo "kallisto quant -i output/${prefix}/${prefix}.transcripts.idx \
                        -t 12 \
                        -o output/${prefix}/${sample} \
                        -b 100 \
                        input/${sample}.p1.fq.gz \
                        input/${sample}.p2.fq.gz"
        done | parallel -j 3

	echo 'Merging samples ...'
	paste <(echo 'transcript_id') <(ls output/${prefix}/*/abundance.tsv | awk -F'/' '{print  $3}' | tr -t '\n' '\t') > tmp/header.tsv
	paste output/${prefix}/*/abundance.tsv | cut -f 1 | sed 1d > tmp/transcript_id.tsv
	END=$((5*$(ls output/${prefix}/*/abundance.tsv | wc -l)))
	paste output/${prefix}/*/abundance.tsv | cut -f$(seq -s, 5 5 $END) | sed 1d > tmp/expression.tsv
	cat tmp/header.tsv <(paste tmp/transcript_id.tsv tmp/expression.tsv) > output/${prefix}/expression.tsv
	sed -i 's/\t$//g' output/${prefix}/expression.tsv
	echo 'Done'
}

results(){
	for i in $(cut -f 1 output/$prefix.most_shared.tsv | sort -u); do
		n_samples=$(grep -w $i output/${prefix}/expression.tsv | tr -t '\t' '\n' | awk '{if ($1 > 0) print}' | grep -v MSTRG | wc -l)
		echo -e $i'\t'$n_samples >> tmp/${prefix}.nsamplespertranscript.tsv
	done

	Rscript scripts/median.R output/${prefix}/expression.tsv output/${prefix}/median.tsv

	awk -F '.' '{print $0"\t"$1"."$2}' output/$prefix.most_shared.tsv > tmp/$prefix.most_shared.tsv

	#Colocar uma coluna 4 com o id_gene não so o id_trans (MSTRG.X além de MSTRG.X.Y)

	for i in $(cut -f 4 tmp/$prefix.most_shared.tsv | sort -u); do
		head -n1 output/${prefix}/expression.tsv > tmp/chimeric_expression
		head -n1 output/${prefix}/expression.tsv > tmp/host_expression
		grep -w $i tmp/$prefix.most_shared.tsv | cut -f 1 | fgrep -wf - output/${prefix}/expression.tsv >> tmp/chimeric_expression
		grep -w $i tmp/$prefix.most_shared.tsv | cut -f 2 | fgrep -wf - output/${prefix}.merge.gtf | \
		fgrep -v exon | awk -F '"' '{print $4}' | \
		fgrep -wf - output/${prefix}/expression.tsv >> tmp/host_expression
		Rscript scripts/psi.R tmp/host_expression tmp/chimeric_expression $i >> tmp/${prefix}.psi.tsv
	done

	rm tmp/chimeric_expression
	rm tmp/host_expression

	echo -e 'Id\tGene\tTranscript\tEvent_in\tSamples\tExpression_Median\tPsi\tCoding(?)\tObs' > output/${prefix}.results
	join <(sort tmp/${prefix}.most_shared.tsv) <(sort output/${prefix}.info.tsv| cut -f 1,5) | sed 's/Novel //g' | \
	join - <(sort tmp/${prefix}.nsamplespertranscript.tsv) | \
	join - <(sed 's/"//g' output/${prefix}/median.tsv | sort -k1,1) | \
	join -1 4 -2 1 - <(sort tmp/${prefix}.psi.tsv) | \
	join -1 2 -2 1 - <(sort output/${prefix}.classification.tsv | \
	awk '{if ($3 > 0.9) print $1"\tCoding"; else print $1"\tNon-Coding"}') | \
	join -a 1 - <(sort output/${prefix}.info_dom.tsv | cut -f 1,5) | \
	awk '{$2=""; print $0}' - >> output/${prefix}.results

	for i in $(awk '{if ($2 >= 0.15) print $1}' tmp/READ.psi.tsv| sort -u) ; do
		head -n1 output/${prefix}/expression.tsv > tmp/chimeric_expression
		head -n1 output/${prefix}/expression.tsv > tmp/host_expression
		grep -w $i output/$prefix.most_shared.tsv | cut -f 1 | fgrep -wf - output/${prefix}/expression.tsv >> tmp/chimeric_expression
		grep -w $i output/$prefix.most_shared.tsv | cut -f 3 | fgrep -wf - output/${prefix}/expression.tsv >> tmp/host_expression
		Rscript scripts/boxplot.R tmp/host_expression tmp/chimeric_expression $i
	done
}

help(){
	echo "freddie 0.0.1"
	echo ""
	echo "Usage: freddie <CMD> [arguments] .."
	echo ""
	echo "Where <CMD> can be one of:"

	echo -e "\n\tstring\t\tRun StringTie2"
	echo -e "\tchimeric\tFinding potential chimeric transcripts"
	echo -e "\tcoding\t\tEstimates the possibility of a chimeric transcript being coding"
	echo -e "\tpfam\t\tAnalyzes the domains of the sequences generated in relation to the host transcript"
	echo -e "\texpression\tMeasurement of transcript expression by kallisto"
	echo -e "\tresults\t\tCompile results from the previous steps"

	echo -e "\nAnd [arguments] are:"

        echo -e "\n\t-p\tProject Prefix"
        echo -e "\t-a\tWorkDir"
        echo -e "\t-i\tInput path"
        echo -e "\t-t\tThreads"
}

while getopts ":a:i:p:" opt; do
     case $opt in
	a ) abs=$OPTARG ;;
        i ) input=$OPTARG ;;
        p ) prefix=$OPTARG ;;
     esac
done

if [[ -z $1 ]]; then
	help
elif [[ "$1" != "string" && "$1" != "chimeric" && "$1" != "coding" && "$1" != "pfam" && "$1" != "expression" && "$1" != "results"]]; then
	help
else
	$1
fi

