params.reads = "/data/home/project/Nextflow/rawdata/**fastq.gz"            // directory for fastq single-end.
params.reference = "/data/home/project/Nextflow/reference/Reference.fna"  // directory for fasta file.
params.gtf = "/data/home/project/Nextflow/reference/Reference.gtf"       // directory for gtf file.
params.outdir = "/data/home/project/Nextflow/results"                   //  directory for output.
params.outindex = "index"                                              //  directory for index.


include { Fastp } from './modules_single/fastp.nf'
include { FastQC as FastQC_befor } from './modules_single/fastqc.nf'
include { FastQC as FastQC_after } from './modules_single/fastqc.nf'
include { STAR_INDEX; STAR } from './modules_single/star.nf'
include { Qualimap } from './modules_single/qualimap.nf'
include { RSEM_INDEX; RSEM } from './modules_single/rsem.nf'
include { Merge_count } from './modules_single/merge_count.nf'



workflow {
    Channel
        .fromPath(params.reference)
        .set { ref_ch }
    Channel
        .fromPath(params.gtf)
        .set { gtf_ch }
    Channel
        .fromPath(params.reads)
        .set { reads_ch }
    Channel
        .fromPath(params.counts)
        .set { count_ch }
     
 
    
    FastQC_one(reads_ch)  
    fastp_ch = Fastp(reads_ch)
    FastQC_two(fastp_ch)
    gz = fastp_ch.map { [it[0]] }
    star_index_ch = STAR_INDEX(ref_ch,gtf_ch)
    new_gz = gz.combine(star_index_ch)
    star_ch = STAR(new_gz)
    bam_one = star_ch.map { [it[0]] }
    bam_two = star_ch.map { [it[1]] }
    Qualimap(bam_one)
    rsem_index_ch = RSEM_INDEX(ref_ch,gtf_ch)
    bam_new = bam_two.combine(rsem_index_ch)
    rsem_ch = RSEM(bam_new)
    rsem_gene = rsem_ch.map {[it[0]]}
    rsem_iso = rsem_ch.map {[it[1]]}
    all_rsem_iso = rsem_iso.collect()
    all_rsem_gene = rsem_gene.collect()
    Merge_count(all_rsem_iso,all_rsem_gene) // If you don't want to merge files You can close this line.
    
    
}


