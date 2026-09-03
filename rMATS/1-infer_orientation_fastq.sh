#!/bin/bash

#SBATCH --job-name=get_orientation
#SBATCH --time=03:00:00
#SBATCH --mem=32G
#SBATCH --output=orientation_%j.out

# ---- INPUTS ----
star_index=/data/mcarazo/indexes/h_index/index_h149
gtf=/data/mcarazo/indexes/h_index/gencode.v48.primary_assembly.annotation.gtf
bed=/data/mcarazo/indexes/h_index/gencode.v48.primary_assembly.annotation.bed
sample1=/scratch/mcarazo/ongoing/Izaro/SPG7_offtargets/fastp_out/R1_1623_ASO1_trim_1.fq.gz
sample2=/scratch/mcarazo/ongoing/Izaro/SPG7_offtargets/fastp_out/R1_1623_ASO1_trim_2.fq.gz

# ---- set the environment ----
module load Python
conda activate /scratch/mcarazo/envs/STAR

cd /scratch/mcarazo/ongoing/Izaro/SPG7_offtargets
# ---- sample the sequences ----
mkdir tmp
mkdir out
zcat $sample1 | head -n 1000000 > tmp/sample1.fq
zcat $sample2 | head -n 1000000 > tmp/sample2.fq

# align to reference genome
STAR --runThreadN 8 --genomeDir $star_index \
--readFilesIn tmp/sample1.fq tmp/sample2.fq \
--outFileNamePrefix out/get_orientation \
--outSAMunmapped Within \
--outFilterType BySJout \
--outSAMattributes NH HI AS NM MD \
--outFilterMultimapNmax 20 \
--outFilterMismatchNmax 999 \
--outFilterMismatchNoverReadLmax 0.04 \
--alignIntronMin 20 \
--alignIntronMax 1000000 \
--alignMatesGapMax 1000000 \
--alignSJoverhangMin 8 \
--alignSJDBoverhangMin 1 \
--sjdbScore 1 \
--outSAMtype BAM SortedByCoordinate

conda deactivate
conda activate /scratch/mcarazo/envs/rmats-turbo/conda_envs/rmats

# get orientation based on STAR output
#python /scratch/mcarazo/envs/rmats-turbo/conda_envs/rmats/bin/infer_experiment.py -i $(find out/*sortedByCoord.out.bam) -r $bed > orientation.txt
infer_experiment.py -i $(find out/*sortedByCoord.out.bam) -r $bed > orientation_R1ASO1.txt

# clear temporal dirs
rm -R tmp/
rm -R out/

echo "Done!"

#For pair-end RNA-seq, there are two different ways to strand reads (such as Illumina ScriptSeq protocol):

#1++,1–,2+-,2-+ -> fr-secondstrand
#read1 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#read1 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand
#read2 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#read2 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand

#1+-,1-+,2++,2– -> fr-firststrand
#read1 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#read1 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand
#read2 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#read2 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand

# if 1++/1-- is similar to 2++/2-- --> fr-unstranded

#For single-end RNA-seq, there are also two different ways to strand reads:

#++,–- -> fr-secondstrand
#read mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#read mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand
#+-,-+ -> fr-firststrand
#read mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#read mapped to ‘-‘ strand indicates parental gene on ‘+’ strand

# if ++/-- is similar to +-/+- --> fr-unstranded
