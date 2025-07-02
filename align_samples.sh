#!/usr/bin/env bash

#SBATCH --partition jic-long,jic-medium 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --time 1-0:00                             # time (D-H:m)
#SBATCH --mem=40G                                 # memory pool for ALL cores

set -euo pipefail

mkdir -p aligned_samples

input_file="pool_1_2_paths.txt"
ref_genome="/jic/scratch/projects/bravo/magilin/resources/genomes/ro18_ensembl_release59/Brassica_rapa_ro18.SCU_BraROA_2.3.dna.toplevel.fa.gz"
cpus=${SLURM_CPUS_PER_TASK}

#load bwa
source package fa33234e-dceb-4a58-9a78-7bcf9809edd7

# map paired-end reads to reference genome
echo "--> $(date "+%F %T") : aligning reads to ro18-genome"
for sample_1 in $(cat $input_file);
    do  
        echo "--> $(date "+%F %T") : aligning ${sample_1}"

        sample_2=$(echo ${sample_1} |  sed 's/_1_trimmed.fq.gz/_2_trimmed.fq.gz/')
        sample_id=$(basename $sample_1 | sed 's/_1_trimmed.fq.gz//' )
        output_sam="${sample_id}_aligned.sam"

        bwa mem \
            -t ${cpus} \
            ro18-genome \
            $sample_1 \
            $sample_2 > aligned_samples/$output_sam

    done

echo "--> $(date "+%F %T") : finished aligning reads to ro18-genome"