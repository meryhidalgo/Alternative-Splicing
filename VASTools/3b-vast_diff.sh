#!/usr/bin/env bash
#SBATCH --time=48:00:00
#SBATCH --qos=regular
#SBATCH --nodes=1
#SBATCH --partition=biogipuzkoa-exclusive
#SBATCH --account=biogipuzkoa-exclusive
#SBATCH --mem=48G
#SBATCH -c 6
#SBATCH -o vast_diff_%A.out

module load Miniforge3
conda activate /scratch/mcarazo/envs/VASTools

dir="TO BE COMPLETED" #dir where vast_out is located
cd ${dir}

outname="TO BE COMPLETED"

# vast-tools diff: performs a statistical test to assess whether the PSI distributions of the two compared groups are signficantly different.
# it provides functionality to test for differential AS based on replicates and read depth for each event, but will also give reasonable estimates 
# if replicates are not available (Han, Braunschweig et al., 2017).

design=/scratch/mcarazo/ongoing/TDP43-Q331K-F210I_SC/design_F210I.tab

group_A=Mutant #contrast
group_B=WT

A=$(awk -v group="$group_A" '$2 == group {print $1}' "$design" | paste -sd, -)
B=$(awk -v group="$group_B" '$2 == group {print $1}' "$design" | paste -sd, -)


/scratch/mcarazo/envs/VASTools/vast-tools/vast-tools diff \
	-a $A -b $B \
	--minDiff 0.1 -o vast_out -d $outname


# The -r flag represents the minimal probability of acceptance that is required to consider a comparison to be 'believable'. 
# By default this is 0.95, but it can be altered depending on stringency requirements.

