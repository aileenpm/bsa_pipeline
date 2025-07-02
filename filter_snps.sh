#!/usr/bin/env bash

#SBATCH --partition jic-medium
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --time 1-0:00 # time (D-H:m)
#SBATCH --mem=20G # memory pool for ALL cores
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=magilin@nbi.ac.uk
#SBATCH --output ./slurm_output/.%N.%j.out

set -euo pipefail

echo "--> $(date "+%F %T") : Starting SNP filtering and intersection"

# Activate conda environment
echo "--> $(date "+%F %T") : activating conda environment"

conda init bash
. "/hpc-home/magilin/miniconda3/etc/profile.d/conda.sh"
conda activate /jic/scratch/projects/bravo/magilin/resources/mirna-alignment/conda-envs/bsa-freebayes-env

# Define output directory
ZIPDIR="compressed_raw"
mkdir -p "$ZIPDIR"

OUTDIR="filtered_vcfs"
mkdir -p "$OUTDIR"

# compress and index raw .vcf files

for vcf in data/*.vcf; do
    base_vcf=$(basename "$vcf")
    bgzip -c "$vcf" > "${ZIPDIR}/${base_vcf}.gz"
    tabix -p vcf "${ZIPDIR}/${base_vcf}.gz"
done

# 1. Filter VCFs: Keep only biallelic SNPs, remove indels, apply quality filter (QUAL >= 20)
echo "--> Filtering VCFs: biallelic SNPs only, remove indels, QUAL >= 20"

for VCF in $ZIPDIR/*.vcf.gz; 
    do
        SAMPLE_NAME=$(basename $VCF | sed 's/.vcf.gz//')

        echo ${SAMPLE_NAME}

        bcftools view \
            -v snps \
            -m2 -M2 \
            -i 'QUAL>=20' \
            $VCF \
            -Oz -o "$OUTDIR/${SAMPLE_NAME}_biallelic_q20_snps.vcf.gz"

        tabix -p vcf "$OUTDIR/${SAMPLE_NAME}_biallelic_q20_snps.vcf.gz"
    
    done


# 2. Find intersecting SNPs between alternate parent and pools
echo "--> Finding intersecting SNPs between alternate parent and early/late pools"

QUAL_THRESHOLD=20

# Early pool intersection
bcftools isec -n=2  -c none \
    "$OUTDIR/sarisha_freebayes_biallelic_q20_snps.vcf.gz" \
    "$OUTDIR/early_pool_freebayes_biallelic_q20_snps.vcf.gz" \
    -O z -p "$OUTDIR/isec_early"

awk -v OFS='\t' '{print $1, $2}' $OUTDIR/isec_early/sites.txt > $OUTDIR/early_sites.txt
bcftools view -R $OUTDIR/early_sites.txt $OUTDIR/early_pool_freebayes_biallelic_q20_snps.vcf.gz -Oz -o $OUTDIR/early_pool_filtered.vcf.gz


# Late pool intersection
bcftools isec -n=2 -c all \
    "$OUTDIR/sarisha_freebayes_biallelic_q20_snps.vcf.gz" \
    "$OUTDIR/late_pool_freebayes_biallelic_q20_snps.vcf.gz" \
    -O z -p "$OUTDIR/isec_late"

awk -v OFS='\t' '{print $1, $2}' $OUTDIR/isec_late/sites.txt > $OUTDIR/late_sites.txt
bcftools view -R $OUTDIR/late_sites.txt $OUTDIR/late_pool_freebayes_biallelic_q20_snps.vcf.gz -Oz -o $OUTDIR/late_pool_filtered.vcf.gz


echo "--> Early and late pool filtering complete"

echo "--> $(date "+%F %T") : SNP filtering and intersection complete"
