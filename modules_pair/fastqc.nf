

process FastQC_befor {
    
    publishDir "$params.outdir/FastQC_results", mode: 'copy'
    tag {sample_name}
    cpus 12


    input:
    tuple val (sample_name), path(reads_ch)
    
    output:
    path "*"
   
    


    script:
    """
    fastqc --threads $task.cpus ${reads_ch[0]} ${reads_ch[1]}
    
    """

}

process FastQC_after {
    
    publishDir "$params.outdir/FastQC_results", mode: 'copy'
    tag {sample_name}
    cpus 12


    input:
    tuple val (sample_name), path(reads1_ch), path(reads2_ch)
    
    output:
    path "*"
   
    


    script:
    """
    fastqc --threads $task.cpus ${reads1_ch} ${reads2_ch}
    
    """

}
