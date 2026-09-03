#!/bin/bash

#SBATCH --job-name=rmats_files
#SBATCH -c 5
#SBATCH --mem=32G
#SBATCH --output=rmats_files_%j.out

# ---- set the project directory, it should have a fastp_out dir ----
dir="TO BE COMPLETED"
cd ${dir}

out=rmats_out_ASO1vsNT
mkdir -p $out
fastqs_dir=fastp_out/

# ---- INPUTS ----
design=design.tab

# ---- create the necessary files for running rMATS ----
echo -n > $out/s.txt

group_A=ASO1 #contrast
group_B=NT

A=$(grep $group_A $design | awk '{print $1}')

for line in ${A[@]}; do
    #dev/null me recoge los mensajes de error de aquellas muestras que no encuentra
    fR1=$(realpath $fastqs_dir/"$line"_trim_1.fq.gz 2>/dev/null)
    if [[ -f "$fR1" ]]; then
        fR2=$(echo $fR1 | sed 's/_1.fq.gz/_2.fq.gz/')
        echo -n "$fR1:$fR2," >> $out/s.txt
    else
        echo "Sample $line not compared."
    fi
done

sed '$ s/.$//' $out/s.txt > $out/s1_${group_A}.txt

echo -n > $out/s.txt

B=$(grep $group_B $design | awk '{print $1}')

for line in ${B[@]}; do
    fR1=$(realpath $fastqs_dir/"$line"_trim_1.fq.gz 2>/dev/null)
    if [[ -f "$fR1" ]]; then
        fR2=$(echo $fR1 | sed 's/_1.fq.gz/_2.fq.gz/')
        echo -n "$fR1:$fR2," >> $out/s.txt
    else
        echo "Sample $line not compared."
    fi
done


sed '$ s/.$//' $out/s.txt > $out/s2_${group_B}.txt

rm $out/s.txt

echo "Files created."