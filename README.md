This is a list of scripts I've used for Bulk Segregant Analysis of F2 population generated from crossing two mustard (Brassica rapa) cultivars with different flowering time phenotypes. 

The aim of this analysis is to identify genomic loci within the alternative parent (Sarisha-14) with SNPs associated to its earlier flowering phenotype, and SNP annotation using SnpEff [1] to predict the impacts of these SNPs on downstream processing of genes within these genomic loci.

This workflow starts with:
1. _align_samples.sh_ : Aligning raw Illumina DNA-sequencing data from Sarisha-14 (alternative parent), early flowering pool and late flowering pool against reference B. rapa genome (R-o-18), using bwa [2]. 
2. _process_sam.sh/process_sam.slurm & prep_sample.sh_ : Prepping alignment .sam files for variant calling. 
3. _freebayes.sh_ : Running variant calling on alternative parent alignment using Freebayes [3].
4. _filter_snps.sh_ : Identify SNPs from alternative parent present in the early and late flowering pools using bcftools isec [4].
5. _parse_vcf.sh & make_table.sh_ : Custom scripts to parse through annotated SNPs and create a results table with priority for HIGH impact snps.
6. _09-new-snp-allele-freq.Rmd_ : Custom script calculating SNP allele frequencies from early and late pools (SNP-index) and the differences between both pools (delta SNP-index), and data visualisation of SNPs across each chromosome.

References:
1. "A program for annotating and predicting the effects of single nucleotide polymorphisms, SnpEff: SNPs in the genome of Drosophila melanogaster strain w1118; iso-2; iso-3.", Cingolani P, Platts A, Wang le L, Coon M, Nguyen T, Wang L, Land SJ, Lu X, Ruden DM. Fly (Austin). 2012 Apr-Jun;6(2):80-92. PMID: 22728672
2. Li, H. & Durbin, R., 2009. Fast and accurate short read alignment with Burrows–Wheeler transform. bioinformatics, 25(14), pp.1754–1760.
3. Garrison E, Marth G. Haplotype-based variant detection from short-read sequencing. arXiv preprint arXiv:1207.3907 [q-bio.GN] 2012
4. Danecek P, Bonfield JK, et al. Twelve years of SAMtools and BCFtools. Gigascience (2021) 10(2):giab008

