#!/usr/bin/env nextflow

/*================================================================
The MORETT LAB presents...

  The gnomAD coverage liftover pipeline

- A genome coordinates convertion tool

==================================================================
Version: 0.0.1
Project repository: https://github.com/Iaguilaror/nf-gnomAD-coverage-liftover
==================================================================
Authors:

- Bioinformatics Design
 Israel Aguilar-Ordonez (iaguilaror@gmail)

- Bioinformatics Development
 Israel Aguilar-Ordonez (iaguilaror@gmail)

- Nextflow Port
 Israel Aguilar-Ordonez (iaguilaror@gmail)

=============================
Pipeline Processes In Brief:

Pre-processing:
	_pre1_split_data

Core-processing:
	_001_tsv2bed
	_002_liftover
  _003_sort_compress

Post-processing:
	_pos1_count_lifted_positions

================================================================*/

/* Define the help message as a function to call when needed *//////////////////////////////
def helpMessage() {
	log.info"""
  ==========================================
  The gnomAD coverage liftover pipeline
  - A genome coordinates convertion tool
  v${version}
  ==========================================

	Usage:

  nextflow run liftover-coverage.nf --covfile <path to input 1> ----chainfile <path to input 2> [--output_dir path to results] [--chunks INT]

    --covfile    <- compressed TSV file with coverage dara downloaded from gnomAD;
		    file must be in .tsv.bgz format
    --chainfile   <- UCSC chainfile to perform coordinate conversion;
        extension must be .chain; file must be uncompressed
        find them at http://crossmap.sourceforge.net/#chain-file
    --output_dir     <- directory where results, intermediate and log files will be stored;
				default: same level dir where --covfile resides
		--chunks		<- The TSV covfile will be split in INT pieces per chromosome for parallelization;
				default: 1
	  --help           <- Show Pipeline Information
	  --version        <- Show Pipeline version
	""".stripIndent()
}

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
version = "0.0.1"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
pipeline_name = "gnomADcoverageliftover"

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.covfile = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.chainfile = false //default is false to not trigger help message automatically at every run
params.chunks = 1 //default is 1, to not split each chromosome
params.help = false //default is false to not trigger help message automatically at every run
params.version = false //default is false to not trigger version message automatically at every run

/*//////////////////////////////
  If the user inputs the --help flag
  print the help message and exit pipeline
*/
if (params.help){
	helpMessage()
	exit 0
}

/*//////////////////////////////
  If the user inputs the --version flag
  print the pipeline version
*/
if (params.version){
	println "gnomAD coverage liftover Pipeline v${version}"
	exit 0
}

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by iaguilar at FEB 2019
*/
nextflow_required_version = '19.01'
/*
  Try Catch to verify compatible Nextflow version
  If user Nextflow version is lower than the required version pipeline will continue
  but a message is printed to tell the user maybe it's a good idea to update her/his Nextflow
*/
try {
	if( ! nextflow.version.matches(">= $nextflow_required_version") ){
		throw GroovyException('Your Nextflow version is older than Extend Align required version')
	}
} catch (all) {
	log.error "-----\n" +
			"  Pipeline requires Nextflow version: $nextflow_required_version \n" +
      "  But you are running version: $workflow.nextflow.version \n" +
			"  Pipeline will continue but some things may not work as intended\n" +
			"  You may want to run `nextflow self-update` to update Nextflow\n" +
			"============================================================"
}

/*//////////////////////////////
  INPUT PARAMETER VALIDATION BLOCK
  TODO (iaguilar) check the extension of input queries; see getExtension() at https://www.nextflow.io/docs/latest/script.html#check-file-attributes
*/

/* NONE */

/*
Output directory definition
Default value to create directory is the parent dir of --covfile
*/
params.output_dir = file(params.covfile).getParent()

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable (pipeline_name) defined by this Script

  This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*//////////////////////////////
  LOG RUN INFORMATION
*/
log.info"""
==========================================
The gnomAD coverage liftover pipeline
- A genome coordinates convertion tool
v${version}
==========================================
"""
log.info "--Nextflow metadata--"
/* define function to store nextflow metadata summary info */
def nfsummary = [:]
/* log parameter values beign used into summary */
/* For the following runtime metadata origins, see https://www.nextflow.io/docs/latest/metadata.html */
nfsummary['Resumed run?'] = workflow.resume
nfsummary['Run Name']			= workflow.runName
nfsummary['Current user']		= workflow.userName
/* string transform the time and date of run start; remove : chars and replace spaces by underscores */
nfsummary['Start time']			= workflow.start.toString().replace(":", "").replace(" ", "_")
nfsummary['Script dir']		 = workflow.projectDir
nfsummary['Working dir']		 = workflow.workDir
nfsummary['Current dir']		= workflow.launchDir
nfsummary['Launch command'] = workflow.commandLine
log.info nfsummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "\n\n--Pipeline Parameters--"
/* define function to store nextflow metadata summary info */
def pipelinesummary = [:]
/* log parameter values beign used into summary */
pipelinesummary['Coverage file']			= params.covfile
pipelinesummary['ChainFile']			= params.chainfile
pipelinesummary['Chunks per chromosome']			= params.chunks
pipelinesummary['Results Dir']		= results_dir
pipelinesummary['Intermediate Dir']		= intermediates_dir
/* print stored summary info */
log.info pipelinesummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "==========================================\nPipeline Start"

/*//////////////////////////////
  PIPELINE START
*/

/*
	DEFINE PATHS TO MK MODULES
  -- every required file (mainly runmk.sh and mkfile, but also every accessory script)
  will be moved from these paths into the corresponding process work subdirectory during pipeline execution
  The use of ${workflow.projectDir} metadata guarantees that mkmodules
  will always be retrieved from a path relative to this NF script
*/

/*  _pre1_split_data */
module_mk_pre1_split_data = "${workflow.projectDir}/mkmodules/mk-index-extract-split-chromosomes"

/*	_001_tsv2bed */
module_mk_001_tsv2bed = "${workflow.projectDir}/mkmodules/mk-tsv2bed-edit"

/*	_002_liftover */
module_mk_002_liftover = "${workflow.projectDir}/mkmodules/mk-liftover"

/*  _003_sort_compress */
module_mk_003_sort_compress = "${workflow.projectDir}/mkmodules/mk-concatenate-sort-compress-bed"

/*	_pos1_count_lifted_positions */
module_mk_pos1_count_lifted_positions = "${workflow.projectDir}/mkmodules/mk-count-lifted-positions"

/*
	READ INPUTS
*/

/* Load covfile into channel */
Channel
  .fromPath("${params.covfile}")
  .into{ covfile_input; again_covfile_input }

/* Process _pre1_split_data */
/* Read mkfile module files */
Channel
	.fromPath("${module_mk_pre1_split_data}/*")
	.toList()
	.set{ mkfiles_pre1 }

process _pre1_split_data {

	publishDir "${intermediates_dir}/_pre1_split_data/",mode:"symlink"

	input:
  file covfile from covfile_input
	file mk_files from mkfiles_pre1

	output:
	file "*.tsv" into results_pre1_split_data mode flatten

	"""
	export NUMBER_OF_CHUNKS="${params.chunks}"
	bash runmk.sh
	"""

}

/* Process _001_tsv2bed */
/* Read mkfile module files */
Channel
	.fromPath("${module_mk_001_tsv2bed}/*")
	.toList()
	.set{ mkfiles_001 }

process _001_tsv2bed {

	publishDir "${intermediates_dir}/_001_tsv2bed/",mode:"symlink"

	input:
  file tsvfile from results_pre1_split_data
	file mk_files from mkfiles_001

	output:
	file "*.bed" into results_001_tsv2bed mode flatten

	"""
	bash runmk.sh
	"""

}

/* Process _002_liftover */
/* Load chainfile into channel */
Channel
	.fromPath( "${params.chainfile}", checkIfExists: true)
	.combine(results_001_tsv2bed)
	.set{ liftover_inputs }

/* Read mkfile module files */
Channel
	.fromPath("${module_mk_002_liftover}/*")
	.toList()
	.set{ mkfiles_002 }

process _002_liftover {

	publishDir "${intermediates_dir}/_002_liftover/",mode:"symlink"

	input:
  file bedfile from liftover_inputs
	file mk_files from mkfiles_002

	output:
	file "*.liftover.bed" into results_002_liftover
	file "*.liftover.bed.unmap"

	"""
	export CHAINFILE="\$(ls *.chain)"
	bash runmk.sh
	"""

}

/* _003_sort_compress */
/* gather all of the chunks */
results_002_liftover
	.toList()
	.set{ all_chunks_002 }

/* Read mkfile module files */
Channel
	.fromPath("${module_mk_003_sort_compress}/*")
	.toList()
	.set{ mkfiles_003 }

process _003_sort_compress {

	publishDir "${results_dir}/_003_sort_compress/",mode:"copy"

	input:
  file chunks from all_chunks_002
	file mk_files from mkfiles_003

	output:
	file "*.bed.gz" into results_003_sort_compress

	"""
	bash runmk.sh
	"""

}

/* Process _pos1_count_lifted_positions */
/* Read mkfile module files */
Channel
	.fromPath("${module_mk_pos1_count_lifted_positions}/*")
	.toList()
	.set{ mkfiles_pos1 }

process _pos1_count_lifted_positions {

	publishDir "${results_dir}/_pos1_count_lifted_positions/",mode:"copy"

	input:
  file liftedbed from results_003_sort_compress
	file unliftedtsv from again_covfile_input
	file mk_files from mkfiles_pos1

	output:
	file "*.pdf"
	file "*.tmp"

	"""
	bash runmk.sh
	"""

}
