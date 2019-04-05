#!/bin/bash

nextflow run liftover-coverage.nf \
	--covfile real-data/genomes/gnomad.genomes.coverage.summary.tsv.bgz \
	--chainfile test/reference/GRCh37_to_GRCh38.chain \
	--chunks 20 \
	--output_dir real-data/genomes/results \
	-resume \
	-with-report real-data/genomes/results/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag real-data/genomes/results/`date +%Y%m%d_%H%M%S`.DAG.html
