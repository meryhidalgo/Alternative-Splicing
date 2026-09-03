#!/bin/bash

#SBATCH --qos=long
#SBATCH -c 5
#SBATCH --mem=20G
#SBATCH -o %x_%A_%a.out
#SBATCH --array=0-5%6

#module load VAST-TOOLS/2.5.1
module load Miniforge3
conda activate /scratch/mcarazo/envs/VASTools

dir="TO BE COMPLETED"
cd ${dir}

mkdir -p vast_out

VASTDB="/scratch/mcarazo/envs/VASTools/VASTDB" # path to VastDB

# Select the fastq files
fastqs=($(realpath fastp_out/*_trim_R1.fq.gz))


fq1=${fastqs[$SLURM_ARRAY_TASK_ID]}
fq2=${fq1/_trim_R1.fq.gz/_trim_R2.fq.gz}
base=$(basename ${fq1} _trim_R1.fq.gz)

/scratch/mcarazo/envs/VASTools/vast-tools/vast-tools align \
    $fq1 $fq2 \
    --sp "hg38" \
    --name $base \
    --dbDir $VASTDB \
    --cores 5 \
    --resume

