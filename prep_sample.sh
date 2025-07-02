#!/usr/bin/env bash

#SBATCH --partition jic-medium
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --array=1-4
#SBATCH --output ./slurm_output/prep_sample.%N.%j.out
#SBATCH --time 1-0:00                             # time (D-H:m)
#SBATCH --mem=40G                                 # memory pool for ALL cores
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=magilin@nbi.ac.uk


echo "--> $(date "+%F %T") : HELLO I'M running script prep_sample.sh"

# strict mode
set -euo pipefail


# activate conda environment
echo "--> $(date "+%F %T") : activating conda environment"

conda init bash

. "/hpc-home/magilin/miniconda3/etc/profile.d/conda.sh"

conda activate /jic/scratch/projects/bravo/magilin/resources/mirna-alignment/conda-envs/bsa-freebayes-env


# set input files
file_list=$1
bam_file=$(awk "NR == ${SLURM_ARRAY_TASK_ID}" ${file_list})
sample_id=$(basename ${bam_file} | sed 's/_sorted_dedup.bam//' )

echo "--> $(date "+%F %T") : procesing sample : ${bam_file}"

## index genome file
#echo "--> $(date "+%F %T") : indexing genome"
#
#bgzip -cd /jic/scratch/projects/bravo/magilin/resources/genomes/ro18_ensembl_release59/Brassica_rapa_ro18.SCU_BraROA_2.3.dna.toplevel.fa.gz > ro18-genome.fa
#
#samtools faidx ro18-genome.fa

# filter reads
echo "--> $(date "+%F %T") : filtering q20 reads"

samtools view -h -b -q 20 $bam_file > ${sample_id}_sorted_dedup_q20.bam

# index bam files
echo "--> $(date "+%F %T") : indexing .bam files"

bamtools index -in ${sample_id}_sorted_dedup_q20.bam

conda deactivate

echo "--> $(date "+%F %T") : sample prep complete"
