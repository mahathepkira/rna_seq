
process Fastp {
    
    publishDir "$params.outdir/Fastp_results", pattern: '*.q20.cutadap.gz'
    publishDir "$params.outdir/Fastp_results/json", pattern: '*.json'
    publishDir "$params.outdir/Fastp_results/html", pattern: '*.html'
    cpus 12 // You can change the thread with this line.
    tag {reads}

    input:
    path reads

    output:
    path "*"

    script:
    """
    fastp -i $reads -o "$reads".q20.cutadap.gz -q 20 --adapter_sequence AGATCGGAAGAG \ # You can change the adapter with this line.
    --html "$reads".q20.cutadap.gz.html --json "$reads".q20.cutadap.gz.json --thread $task.cpus
    
    """

}

