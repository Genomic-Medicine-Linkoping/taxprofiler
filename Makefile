.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS := -e -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# The conda env definition file "requirements.yml" is located in the project's root directory
CURRENT_CONDA_ENV_NAME = nf-core
ACTIVATE_CONDA = source $$(conda info --base)/etc/profile.d/conda.sh
CONDA_ACTIVATE = $(ACTIVATE_CONDA) ; conda activate ; conda activate $(CURRENT_CONDA_ENV_NAME)

.PHONY: \
test \
install \
update_env \
clean \
help

OUTPUT_DIR = 20220905_pp1_results

## run: Run pipeline
run:
	$(CONDA_ACTIVATE)
	export SINGULARITY_TMPDIR="/data/Twist_Solid/cache_dir"
	export TMPDIR="/data/Twist_Solid/cache_dir"
	nextflow run . \
	-profile singularity \
	--outdir $(OUTPUT_DIR) \
    --input assets/samplesheet.csv \
    --databases assets/database.csv \
    --run_centrifuge \
    --run_kraken2 \
    --run_kaiju \
    --run_krona \
    --perform_shortread_qc \
    --perform_shortread_complexityfilter \
    -resume


#--perform_shortread_hostremoval
#--hostremoval_reference /data/reference_genomes/hg38/hg38.fa.gz


lint:
	$(CONDA_ACTIVATE)
	nf-core lint

prettier:
	$(CONDA_ACTIVATE)
	prettier --check .

install:
	$(CONDA_ACTIVATE)
	nf-core modules install --force samtools/bam2fq


update_module:
	$(CONDA_ACTIVATE)
	nf-core modules update minimap2/align


show_modules:
	$(CONDA_ACTIVATE)
	nf-core modules list remote


## update_env: Update conda environment to the latest version defined by env.yml file
update_env:
	$(ACTIVATE_CONDA)
	mamba env update --file env.yml

## clean: Remove all the latest results
clean:
	rm --verbose --recursive --force $(RESULTS)

## help: Show this message
help:
	@grep '^##' ./Makefile
