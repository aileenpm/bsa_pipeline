#!/usr/bin/bash

# Usage:
# ./parse_snpeff_to_genes.sh input_file.tsv output_file.tsv

# Check input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input_file.tsv output_file.tsv"
    exit 1
fi

INPUT="$1"
OUTPUT="$2"

awk -F'\t' '
BEGIN { OFS="\t" }
NR==1 { next }  # Skip header
{
    chr = $1;
    pos = $2;
    ref_alt = $3;
    gene = $4;
    impact = $5;
    effect = $6;
    hgvs = $7;

    # Prioritize impacts: HIGH < MODERATE < LOW < MODIFIER
    impact_priority = (impact=="HIGH" ? 1 : (impact=="MODERATE" ? 2 : (impact=="LOW" ? 3 : 4)));

    # Keep best SNP per gene
    if (!(gene in best_priority) || impact_priority < best_priority[gene]) {
        best_chr[gene] = chr;
        best_pos[gene] = pos;
        best_refalt[gene] = ref_alt;
        best_effect[gene] = effect;
        best_impact[gene] = impact;
        best_hgvs[gene] = hgvs;
        best_priority[gene] = impact_priority;
    }

    # Count good SNPs (only HIGH/MODERATE)
    if (impact_priority <= 2) {
        snp_count[gene]++;
    }
}
END {
    for (g in best_chr) {
        if (g in snp_count) {  # Only genes with good SNPs
            priority = (best_impact[g]=="HIGH" ? 1 : (best_impact[g]=="MODERATE" ? 2 : (best_impact[g]=="LOW" ? 3 : 4)));
            print priority, g, best_chr[g], best_pos[g], best_refalt[g], best_effect[g], best_impact[g], best_hgvs[g], snp_count[g];
        }
    }
}' "$INPUT" | sort -k1,1n -k2,2d | awk -F'\t' 'BEGIN { OFS="\t"; print "GENE", "CHR", "POS", "REF>ALT", "EFFECT", "IMPACT", "HGVS", "NUM_SNPS" }
{ print $2, $3, $4, $5, $6, $7, $8, $9 }' > "$OUTPUT"

echo "Parsing and sorting completed! Output written to: $OUTPUT"
