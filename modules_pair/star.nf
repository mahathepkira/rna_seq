
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
    STAR --runThreadN $task.cpus --runMode genomeGenerate --genomeDir STAR_index --genomeFastaFiles $reference --sjdbGTFfile $gtf --sjdbOverhang 150
    """

}

process STAR {

    cpus 12 // You can change the thread with this line.
    tag {sample_name}

    publishDir "$params.outdir/STAR_results", mode: 'copy'

    input:
    tuple val(sample_name), path(read1_ch), path(read2_ch), path(index_ch)
    

    output:
    tuple val(sample_name), path("${sample_name}.Aligned.sortedByCoord.out.bam"), path("${sample_name}.Aligned.toTranscriptome.out.bam"), path("${sample_name}.Log.final.out"), path("${sample_name}.Log.out"), path("${sample_name}.Log.progress.out"), path("${sample_name}.SJ.out.tab")

    script:
    """
    
    STAR --genomeDir ${index_ch} \
         --runThreadN $task.cpus --readFilesIn ${read1_ch} ${read2_ch} --readFilesCommand zcat \
         --outFileNamePrefix $sample_name. --outFilterMultimapNmax 1 --outSAMunmapped Within --outSAMtype BAM SortedByCoordinate \
         --quantMode TranscriptomeSAM
    """

}


