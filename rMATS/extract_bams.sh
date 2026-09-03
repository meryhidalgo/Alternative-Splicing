#!/bin/bash

#SBATCH --job-name=extract_bams
#SBATCH --time=01:00:00
#SBATCH --output=ebams_%j.out

rmats_dir="TO BE COMPLETED" # a tmp folder should be found here
cd ${rmats_dir}

mkdir -p bams

folders=($(ls -d tmp/*/))

for folder in "${folders[@]}"; do
	# Extract the basename of the read file from the log.out
	basename=$(grep "readFilesIn" ${folder}/Log.out | awk 'NR==1{print $28}' | sed 's|.*/||; s|_R[12]\.fastq\.gz||')

	# COPYING (not moving) the BAM file
	cp ${folder}/Aligned.sortedByCoord.out.bam "bams/${basename}.bam"
done

