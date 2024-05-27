
process RSEM_INDEX {
    
    cpus 12
    publishDir "$params.outindex/RSEM_index", mode: 'copy'
    tag {reference}

    input:
    path reference
    path gtf

    output:
    path "*"

    script:
    """
    rsem-prepare-reference --gtf $gtf $reference --num-threads $task.cpus cassava_ref 
    """
}


process RSEM {
    cpus 12
    publishDir "$params.outdir/RSEM_results", mode: 'copy'
    tag {bam}
    
    input:
    tuple path (bam), path (index_ch1), path (index_ch2), path (index_ch3), path (index_ch4), path (index_ch5), path (index_ch6), path (index_ch7)
   
    output:
    path "*"
    
    script:
    """
    rsem-calculate-expression --bam --no-bam-output --num-threads $task.cpus ${bam} cassava_ref ${bam}
    """

} 





    
    
    
    
  
