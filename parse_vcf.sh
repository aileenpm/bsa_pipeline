#!/usr/bin/bash

# Make sure input file is provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <input_vcf> <output_file>"
    exit 1
fi

# Input and output files
INPUT_VCF=$1
OUTPUT_FILE=$2

# Step 1: Process VCF using AWK to extract relevant SNP info and prioritize annotations
awk -F'\t' '
BEGIN { OFS="\t"; print "CHR", "POS", "REF>ALT", "GENE", "IMPACT", "EFFECT", "HGVS" }
!/^#/ {
    if ( $1 == "A02" && $2 >= 0 && $2 <= 10000000) {
        split($8, info, ";");
        for (i in info) {
            if (info[i] ~ /^ANN=/) {
                annstr = substr(info[i], 5);
                split(annstr, annotations, ",");
                
                best_priority = 99;
                best_gene = best_impact = best_effect = best_hgvs = "-";
                
                for (j in annotations) {

                    split(annotations[j], fields, "|");
                    impact=fields[3];
                    priority = (impact=="HIGH" ? 1 : (impact=="MODERATE" ? 2 : (impact=="LOW" ? 3 : 4)));
                    

                    if (priority < best_priority) {
                        best_priority = priority;
                        best_gene = fields[4];
                        best_impact = impact;
                        best_effect = fields[2];
                        best_hgvs = fields[10];
                        

                        if (priority == 1) break;
                    }
                }
                

                print $1, $2, $4 ">" $5, best_gene, best_impact, best_effect, best_hgvs;
                break;
            }
        }
    }
}' "$INPUT_VCF" | \
# Step 2: Sort by impact priority and output in desired format
awk -F'\t' '
BEGIN { OFS="\t" }
NR==1 { header=$0; next }  # Save header line
{

    priority = ( $5=="HIGH" ? 1 : ($5=="MODERATE" ? 2 : ($5=="LOW" ? 3 : 4)) );
    print priority, $0;
}' | sort -k1,1n | cut -f2- | \
# Final Step: Clean up header and ensure format
awk 'NR==1{print "CHR\tPOS\tREF>ALT\tGENE\tIMPACT\tEFFECT\tHGVS"} NR>1{print}' > "$OUTPUT_FILE"

echo "Processing complete. Results saved to: $OUTPUT_FILE"
