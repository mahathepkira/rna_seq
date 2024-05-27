

process FastQC {
    
    publishDir "$params.outdir/FastQC_results", mode: 'copy'
    tag {reads}
    cpus 12 // You can change the thread with this line.

    input:
    path reads

    output:
    path "*"

    script:
    """
  
    fastqc --threads $task.cpus ${reads[0]} 

    """

}
