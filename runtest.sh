#!/usr/local/env bash

echo -e "======\n Testing NF execution \n======" \
&& rm -rf test/results/ \
&& nextflow run liftover-coverage.nf \
	--covfile test/data/sample_gnomad.genomes.coverage.summary.tsv.bgz \
	--chainfile test/reference/GRCh37_to_GRCh38.chain \
	--chunks 2 \
	--output_dir test/results \
	-resume \
	-with-report test/results/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag test/results/`date +%Y%m%d_%H%M%S`.DAG.html \
&& echo -e "======\n Extend Align: Basic pipeline TEST SUCCESSFUL \n======"
