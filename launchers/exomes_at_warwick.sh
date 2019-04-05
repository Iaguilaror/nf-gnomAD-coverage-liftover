#!/bin/bash

nextflow run liftover-coverage.nf \
	--covfile real-data/exomes/gnomad.exomes.coverage.summary.tsv.bgz \
	--chainfile test/reference/GRCh37_to_GRCh38.chain \
	--chunks 10 \
	--output_dir real-data/exomes/results \
	-resume \
	-with-report real-data/exomes/results/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag real-data/exomes/results/`date +%Y%m%d_%H%M%S`.DAG.html
