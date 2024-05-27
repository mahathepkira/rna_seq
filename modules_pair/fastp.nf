
process Fastp {
    
    publishDir "$params.outdir/Fastp_results", pattern: '*_q20.cutadap.gz'
    publishDir "$params.outdir/Fastp_results/json", pattern: '*.json'
    publishDir "$params.outdir/Fastp_results/html", pattern: '*.html'
    cpus 12 // You can change the thread with this line.
    tag {sample_name}

    input:
    tuple val (sample_name), path (reads_ch)

    output:
    tuple val(sample_name), path("${sample_name}_R1_q20.cutadap.gz"), path("${sample_name}_R2_q20.cutadap.gz"), path("${sample_name}_q20.cutadap.gz.html"), path("${sample_name}_q20.cutadap.gz.json")
    
    

    script:
    """
    fastp --in1 ${reads_ch[0]} --out1 ${sample_name}_R1_q20.cutadap.gz \
          --in2 ${reads_ch[1]} --out2 ${sample_name}_R2_q20.cutadap.gz \
          --qualified_quality_phred 20 \
          --detect_adapter_for_pe \
          --trim_poly_g --trim_poly_x \
          --adapter_sequence AGATCGGAAGAG \  # You can change the adapter with this line.
          --html ${sample_name}_q20.cutadap.gz.html \
          --json ${sample_name}_q20.cutadap.gz.json \
          --thread $task.cpus
    
    """

}

