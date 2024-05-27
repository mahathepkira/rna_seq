params.fqpairs = "/data/home/project/Nextflow/rawdata/*_R{1,2}.fastq.gz"    // directory for fastq pair-end.
params.reference = "/data/home/project/Nextflow/reference/Reference.fna"   // directory for fasta file.
params.gtf = "/data/home/project/Nextflow/reference/Reference.gtf"        // directory for gtf file.
params.outdir = "/data/home/project/Nextflow/results"                    // directory for output.
params.outindex = "/data/home/project/Nextflow/index"                   // directory for index.



include { Fastp } from './modules_pair/fastp.nf'
include { FastQC_befor } from './modules_pair/fastqc.nf'
include { FastQC_after } from './modules_pair/fastqc.nf'
include { STAR_INDEX; STAR } from './modules_pair/star.nf'
include { Qualimap } from './modules_pair/qualimap.nf'
include { RSEM_INDEX; RSEM } from './modules_pair/rsem.nf'


workflow {
    Channel
        .fromPath(params.reference)
        .set { ref_ch }
    Channel
        .fromPath(params.gtf)
        .set { gtf_ch }
    Channel
        .fromFilePairs(params.fqpairs)
        .set { fqpairs_ch } 
    
    
    FastQC_befor(fqpairs_ch)
    fastp_ch = Fastp(fqpairs_ch)
    newfastp_ch = fastp_ch.map { [it[0], it[1], it[2]] }
    FastQC_after(newfastp_ch)
    star_index_ch = STAR_INDEX(ref_ch, gtf_ch)
    star_input = newfastp_ch.combine(star_index_ch)
    star_ch = STAR(star_input)
    bam_one = star_ch.map { [it[0], it[1]] }
    bam_two = star_ch.map { [it[0], it[2]] }
    Qualimap(bam_one)
    rsem_idx = RSEM_INDEX(ref_ch, gtf_ch)
    bam_new = bam_two.combine(rsem_idx)
    rsem_ch = RSEM(bam_new)
    rsem_gene = rsem_ch.map {[it[0]]}
    rsem_iso = rsem_ch.map {[it[1]]}
    all_rsem_iso = rsem_iso.collect()
    all_rsem_gene = rsem_gene.collect()
    Merge_count(all_rsem_iso,all_rsem_gene) // If you don't want to merge files You can close this line.
    
    
}


