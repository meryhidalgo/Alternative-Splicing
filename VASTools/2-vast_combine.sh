#!/usr/bin/env bash

#SBATCH --time=12:00:00
#SBATCH --qos=regular
#SBATCH --nodes=1
#SBATCH --partition=biogipuzkoa-exclusive
#SBATCH --account=biogipuzkoa-exclusive
#SBATCH --mem=12G
#SBATCH -c 5
#SBATCH -o vast_combine_%A.out

module load Miniforge3
conda activate /scratch/mcarazo/envs/VASTools

# To run this process
dir="TO BE COMPLETED"
cd ${dir}

VASTDB="/scratch/mcarazo/envs/VASTools/vast-tools/VASTDB" # path to VastDB

/scratch/mcarazo/envs/VASTools/vast-tools/vast-tools combine \
  -o "${dir}/vast_out" \
  -sp "hg38" \
  --dbDir "$VASTDB" \
  --cores 5
