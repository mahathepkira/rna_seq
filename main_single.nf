params.reads = "/data/home/lattapol/casava_project/Nextflow/single/rawdataS73-S75/**fastq.gz"
params.reference = "/data/home/lattapol/casava_project/Nextflow/single/ref/M.esculenta_v8_genomic.fna"
params.gtf = "/data/home/lattapol/casava_project/Nextflow/single/ref/M.esculenta_v8_genomic_new.gtf"
params.outdir = "/data/home/lattapol/casava_project/Nextflow/single/test-10_resultsS73-S75"
params.outindex = "index"
params.counts = "/data/home/lattapol/casava_project/Nextflow/single/results/RSEM_results"
params.star_index = "/data/home/lattapol/casava_project/Nextflow/single/the_index/STAR_index"
params.rsem_index = "/data/home/lattapol/casava_project/Nextflow/single/the_index/RSEM_index"

include { Fastp } from './modules/fastp.nf'
include { FastQC as FastQC_one } from './modules/fastqc.nf'
include { FastQC as FastQC_two } from './modules/fastqc.nf'
include { STAR_INDEX; STAR } from './modules/star.nf'
include { Qualimap } from './modules/qualimap.nf'
include { RSEM_INDEX; RSEM } from './modules/rsem.nf'
include { Merge_count } from './modules/merge_count.nf'



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
    // rsem_gene = rsem_ch.map {[it[0]]}
    // rsem_iso = rsem_ch.map {[it[1]]}
    // rsem_gene.view()
    // all_rsem = rsem_gene.collect()
    // all_rsem.view()
    
    
}


