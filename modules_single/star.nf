
process STAR_INDEX {

    cpus 12

    publishDir "$params.outindex", mode: 'copy'
    tag {reference}

    input:
    path reference
    path gtf

    output:
    path "STAR_index"

    script:
    """
    STAR --runThreadN $task.cpus --runMode genomeGenerate --genomeDir STAR_index --genomeFastaFiles $reference --sjdbGTFfile $gtf --sjdbOverhang 74
    """

}

process STAR {

    cpus 12
    tag {reads}

    publishDir "$params.outdir/STAR_results", mode: 'copy'

    input:
    tuple path (reads), path (index_ch)
    

    output:
    path "*"

    script:
    """
    
    STAR --genomeDir $index_ch \
         --runThreadN $task.cpus --readFilesIn ${reads} --readFilesCommand zcat \
         --outFileNamePrefix $reads. --outFilterMultimapNmax 1 --outSAMunmapped Within --outSAMtype BAM SortedByCoordinate \
         --quantMode TranscriptomeSAM \
 
    """

}


