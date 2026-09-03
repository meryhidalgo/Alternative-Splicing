#!/usr/bin/env bash
#SBATCH --time=6:00:00
#SBATCH --qos=regular
#SBATCH --partition=general
#SBATCH --mem-per-cpu=128G
#SBATCH -c 6
#SBATCH -o analysis_%A.out

# ---- INPUTS ----

dir="TO BE COMPLETED" #dir where vast_out is located
cd ${dir}

input_table_filt="coverage_filtered_INCLUSION_LEVELS_FULL-hg38-6.tab"
input_table_full="INCLUSION_LEVELS_FULL-hg38-6.tab"
output_dir="TO BE COMPLETED"
design_tab="design.tab"

group_A=mutant #contrast
group_B=WT


min_comparison_pct=50
min_dpsi=10

# ---- SETUP ----

# to create AS-env environment:
# conda create -n AS-env
# conda install -c conda-forge pandas numpy plotly python-kaleido matplotlib scipy

module load Miniforge3
conda activate /scratch/mcarazo/envs/AS-env

# ---- RUN ----
python ../AS_analysis.py $input_table_filt $input_table_full $design_tab $group_A $group_B $output_dir $min_comparison_pct $min_dpsi

# ---- COMPRESS OUTPUT ----
for tab in `ls "${output_dir}/${group_B}_vs_${group_A}_2/tables/"`; do
  gzip "${output_dir}/${group_B}_vs_${group_A}_2/tables/${tab}"
done
