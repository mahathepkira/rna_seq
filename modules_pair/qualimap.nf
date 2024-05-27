
process Qualimap {

    publishDir "$params.outdir/Qualimap_results", mode: 'copy'
    tag {bam}

    input:
    tuple val(sample_name), path(bam)
    
    output:
    path "*"

    script:
    """
    qualimap bamqc -bam $bam
    """

}



