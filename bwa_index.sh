#!/usr/bin/env bash

#SBATCH --partition jic-medium 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --time 1-0:00                             # time (D-H:m)
#SBATCH --mem=40G                                 # memory pool for ALL cores

set -euo pipefail

#load bwa
source package fa33234e-dceb-4a58-9a78-7bcf9809edd7

#index genome
echo "--> $(date "+%F %T") : indexing genome"

bwa index -p ro18-genome /jic/scratch/projects/bravo/magilin/resources/genomes/ro18_ensembl_release59/Brassica_rapa_ro18.SCU_BraROA_2.3.dna.toplevel.fa.gz

echo "--> $(date "+%F %T") : bwa genome index complete"