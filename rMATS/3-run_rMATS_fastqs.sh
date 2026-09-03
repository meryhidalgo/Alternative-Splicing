#!/bin/bash

#SBATCH --job-name=rmats
#SBATCH -c 4
#SBATCH --mem=50G
#SBATCH --output=rmats_%j.out

# ---- set the environment ----
module load Miniforge3
module load GSL
conda activate /scratch/mcarazo/envs/rmats-turbo/conda_envs/rmats

export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:${LD_LIBRARY_PATH:-}"

dir="TO BE COMPLETED"
out="TO BE COMPLETED"
cd ${dir}

# ---- INPUTS ----
star_index=/data/mcarazo/indexes/h_index/index_h149
gtf=/data/mcarazo/indexes/h_index/gencode.v48.primary_assembly.annotation.gtf

group_A=ASO1 #contrast
group_B=NT

paired=paired
strandedness=fr-firststrand
length=150

echo "$(date +"%T") - Starting contrast"

# ---- create the output directories ----
cd $out
mkdir -p output tmp

# ---- run rmats ----
echo "$(date +"%T") - Running rMATS"

#! remember to replace the path to the python and rmats binaries
/scratch/mcarazo/envs/rmats-turbo/conda_envs/rmats/bin/python3 /scratch/mcarazo/envs/rmats-turbo/rmats.py \
    --s1 s1_${group_A}.txt \
    --s2 s2_${group_B}.txt \
    --bi $star_index \
    --gtf $gtf \
    --od output \
    --tmp tmp \
    -t $paired \
    --libType $strandedness \
    --readLength $length \
    --variable-read-length \
    --task both \
    --cstat 0.05 \
    --novelSS
#    --cstat 0.1 \

echo "$(date +"%T") - Finished contrast"