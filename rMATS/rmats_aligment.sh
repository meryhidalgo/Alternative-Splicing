#!/bin/bash

#SBATCH -t 24:00:00
#SBATCH -c 6 
#SBATCH --mem-per-cpu=12G
#SBATCH --job-name=star
#SBATCH --output=star_%j.out
#SBATCH --array=0-2%3

# ---- set the environment ----
module load Miniforge3
conda activate /scratch/mcarazo/envs/rmats-turbo/conda_envs/rmats

dir="TO BE COMPLETED"
cd $dir 

mkdir -p rmats_alignment

star_index=/data/mcarazo/indexes/h_index/index_h149
gtf=/data/mcarazo/indexes/h_index/gencode.v48.primary_assembly.annotation.gtf


fastqs=($(realpath fastp_out/*_trim_R1.fq.gz))
fq1=${fastqs[$SLURM_ARRAY_TASK_ID]}
fq2=${fq1/_R1/_R2}
base=$(basename ${fq1} _trim_R1.fq.gz)


STAR --genomeDir $star_index \
  --readFilesIn  $fq1 $fq2 \
  --readFilesCommand zcat \
  --chimSegmentMin 2 --outFilterMismatchNmax 3 \
  --runThreadN 4 --outSAMstrandField intronMotif \
  --twopassMode Basic --alignEndsType EndToEnd \
  --alignSJDBoverhangMin 1 --alignIntronMax 299999 \
  --sjdbGTFfile $gtf \
  --outFileNamePrefix "/scratch/mcarazo/ongoing/BIOD/fastqs/GSC13/bams/${base}_" \
  --outSAMtype BAM SortedByCoordinate
