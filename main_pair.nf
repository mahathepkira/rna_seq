params.fqpairs = "/data/home/lattapol/casava_project/Nextflow/pair/raw9w/*_R{1,2}_001.fastq.gz"          //  directory for fastq pair-end.
params.reference = "/data/home/lattapol/casava_project/Nextflow/single/ref/M.esculenta_v8_genomic.fna"   // directory for fasta file.
params.gtf = "/data/home/lattapol/casava_project/Nextflow/single/ref/M.esculenta_v8_genomic_new.gtf"    // directory for gtf file.
params.outdir = "/data/home/lattapol/casava_project/Nextflow/pair/results10w"                           //  directory for output.
params.outindex = "/data/home/lattapol/casava_project/Nextflow/pair/index_pair"                         //  directory for index.
params.star_index = "/data/home/lattapol/casava_project/Nextflow/pair/the_index_pair/STAR_index"       //  directory for STAR index if you have a STAR index running elsewhere.



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
        .fromPath(params.star_index)
        .set { star_index_ch }
    Channel
        .fromFilePairs(params.fqpairs)
        .set { fqpairs_ch } 
    
    
    FastQC_befor(fqpairs_ch)
    fastp_ch = Fastp(fqpairs_ch)
    newfastp_ch = fastp_ch.map { [it[0], it[1], it[2]] }
    FastQC_after(newfastp_ch)
    star_input = newfastp_ch.combine(star_index_ch)
    star_ch = STAR(star_input)
    bam_one = star_ch.map { [it[0], it[1]] }
    bam_two = star_ch.map { [it[0], it[2]] }
    Qualimap(bam_one)
    rsem_idx = RSEM_INDEX(ref_ch, gtf_ch)
    bam_new = bam_two.combine(rsem_idx)
    rsem_ch = RSEM(bam_new)
    

    
    
    
    
}


