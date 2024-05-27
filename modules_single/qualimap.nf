
process Qualimap {

    publishDir "$params.outdir/Qualimap_results", mode: 'copy'
    tag {bam}

    input:
    path bam
    
    

    output:
    path "*"

    script:
    """
    qualimap bamqc -bam $bam
    """

}



