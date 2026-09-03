#!/usr/bin/env bash
#SBATCH --time=12:00:00
#SBATCH --qos=regular
#SBATCH --nodes=1
#SBATCH --partition=biogipuzkoa-exclusive
#SBATCH --account=biogipuzkoa-exclusive
#SBATCH --mem=12G
#SBATCH -c 2
#SBATCH -o vast_compare_%A.out

module load Miniforge3
conda activate /scratch/mcarazo/envs/VASTools

dir="TO BE COMPLETED" #dir where vast_out is located
cd ${dir}

# vast-tools compare: pre-filters the events based on read coverage, imbalance and other features, and simply compares average and individual dPSIs. 
# it identifies differentially spliced AS events between two groups (A and B) 
# based mainly on the difference in their average inclusion levels (i.e. ΔPSI = average_PSI_B - average_PSI_A).

# For valid AS events, vast-tools compare then requires that the absolute value of ΔPSI is higher than a threshold 
# provided as --min_dPSI. In addition, it requires that the PSI  distribution of the two groups do not overlap. 
# This can be modified with the --min_range option, to provide higher or lower stringency. 

design=/scratch/mcarazo/ongoing/TDP43-Q331K-F210I_SC/design_F210I.tab

group_A=Mutant #contrast
group_B=WT

A=$(awk -v group="$group_A" '$2 == group {print $1}' "$design" | paste -sd, -)
B=$(awk -v group="$group_B" '$2 == group {print $1}' "$design" | paste -sd, -)

# is it a INCLUSION table will ALL samples????????
n_samples=$(awk 'NR > 1 {n++} END {print n}' "$design")
inclusion_file="vast_out/INCLUSION_LEVELS_FULL-hg38-${n_samples}.tab"

/scratch/mcarazo/envs/VASTools/vast-tools/vast-tools compare \
	$inclusion_file \
	-a $B -b $A \
	-name_A $group_A -name_B $group_B \
	--min_dPSI 10 --min_range 5 \
	--print_dPSI
