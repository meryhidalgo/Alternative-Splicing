#!/usr/bin/env bash

#SBATCH -c 2
#SBATCH --mem=5G

module load Miniforge3
conda activate /scratch/mcarazo/envs/R

vast_dir="TO BE COMPLETED/vast_out"
coverage_filtered_table="coverage_events_INCLUSION_LEVELS_FULL-hg38-295.tab"
full_table="/scratch/mcarazo/ongoing/EGA/vast_out/INCLUSION_LEVELS_FULL-hg38-295.tab"
output_path="coverage_variance_filtered_INCLUSION_LEVELS_FULL-hg38-295.tab"



Rscript Filter_coverage_variance.R $vast_dir $coverage_filtered_table $full_table $output_path