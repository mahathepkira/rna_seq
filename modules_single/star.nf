
process STAR_INDEX {

    cpus 12 // You can change the thread with this line.

    publishDir "$params.outindex", mode: 'copy'
    tag {reference}

    input:
    path reference
    path gtf

    output:
    path "STAR_index"

    script:
    """
    # You set the sjdbOverhang parameter as appropriate for your data ( It will be the longest reads - 1). You can find more information in the STAR manual.
    STAR --runThreadN $task.cpus --runMode genomeGenerate --genomeDir STAR_index --genomeFastaFiles $reference --sjdbGTFfile $gtf --sjdbOverhang 74
    """

}

process STAR {

    cpus 12 // You can change the thread with this line.
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


