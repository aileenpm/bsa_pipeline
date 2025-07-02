#!/usr/bin/env bash

#SBATCH --partition jic-medium 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --array=1-4
#SBATCH --time 1-0:00                             # time (D-H:m)
#SBATCH --mem=40G                                 # memory pool for ALL cores
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=magilin@nbi.ac.uk
#SBATCH --output ./slurm_output/freebayes.%N.%j.out

set -euo pipefail

echo "--> $(date "+%F %T") : HELLO I'M running script freebayes.sh"


# activate conda environment
echo "--> $(date "+%F %T") : activating conda environment"

conda init bash

. "/hpc-home/magilin/miniconda3/etc/profile.d/conda.sh"

conda activate /jic/scratch/projects/bravo/magilin/resources/mirna-alignment/conda-envs/bsa-freebayes-env

# set input files
file_list=$1
bam_file=$(awk "NR == ${SLURM_ARRAY_TASK_ID}" ${file_list})
ref_genome="ro18-genome.fa"

sample_id=$(basename ${bam_file} | sed 's/_sorted_dedup_q20.bam//' )

vcf_file=${sample_id}_freebayes.vcf

# call variants
echo "--> $(date "+%F %T") : procesing sample : ${bam_file}"
echo "--> $(date "+%F %T") : call SNPs with freebayes"

freebayes -p 2 -f $ref_genome $bam_file > variants/$vcf_file

conda deactivate

echo "--> $(date "+%F %T") : SNP calls complete"
