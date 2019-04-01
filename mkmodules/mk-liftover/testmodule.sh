#!/usr/bin/env bash
## This small script runs a module test with the sample data

## Environment Variable
# CHAINFILE="path to the chain file for liftover"
export CHAINFILE="test/reference/GRCh37_to_GRCh38.chain"

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
## results files are *.liftover.bed and *.unmap
./runmk.sh \
&& mv test/data/*.liftover.bed test/data/*.liftover.bed.unmap test/results \
&& echo "[>>>] Module Test Successful"
