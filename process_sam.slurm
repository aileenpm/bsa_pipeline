#!/usr/bin/env bash

#SBATCH --partition jic-medium 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --array=1-4
#SBATCH --time 1-0:00                             # time (D-H:m)
#SBATCH --mem=40G                                 # memory pool for ALL cores


set -euo pipefail

#load samtools v1.18
source package c92263ec-95e5-43eb-a527-8f1496d56f1a
#samtools --version

#make directories
mkdir -p sorted_bam

#set input file
file_list=$1
sam_file=$(awk "NR == ${SLURM_ARRAY_TASK_ID}" ${file_list})
sample_id=$(basename ${sam_file} | sed 's/_aligned.sam//' )

#set output file
tmp_output_sam_file="${sample_id}_tmp.sam"
output_bam_file="${sample_id}.bam"
sorted_bam_file="${sample_id}_sorted.bam"
dedup_bam_file="${sample_id}_sorted_dedup.bam"

# SAM processing

# sort SAM file, then fixmates and compress to BAM
echo "--> $(date "+%F %T") : fix mate and compress sample: ${sam_file}"

samtools sort -n -O sam $sam_file | samtools fixmate -m -O bam - sorted_bam/$output_bam_file

## remove sam file to save space
#rm sorted_bam/evol1.sam

# sort bam file
echo "--> $(date "+%F %T") : sort sample: ${output_bam_file}"

samtools sort -O bam -o sorted_bam/$sorted_bam_file sorted_bam/$output_bam_file

# delete fixmate file to save space
rm sorted_bam/$output_bam_file


# remove PCR duplicates (number of reads not necessary for SNP-calling)
echo "--> $(date "+%F %T") : remove duplicates: ${sorted_bam_file}"

samtools markdup -r -S sorted_bam/$sorted_bam_file sorted_bam/$dedup_bam_file

rm sorted_bam/$sorted_bam_file

echo "--> $(date "+%F %T") : sample processing complete, ready for stats and freebayes"
