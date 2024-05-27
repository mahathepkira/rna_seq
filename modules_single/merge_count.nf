

process Merge_count {

    input:
    path(rsem_iso)
    path(rsem_gene)
    
    script:
    """
    bash /data/home/scripts/merge_count-isofrom.sh
    bash /data/home/scripts/merge_count-gene.sh
    """

} 
