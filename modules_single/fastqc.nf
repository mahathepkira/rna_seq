

process FastQC {
    
    publishDir "$params.outdir/FastQC_results", mode: 'copy'
    tag {reads}
    cpus 12

    input:
    path reads

    output:
    path "*"

    script:
    """
  
    fastqc --threads $task.cpus ${reads[0]} 

    """

}
