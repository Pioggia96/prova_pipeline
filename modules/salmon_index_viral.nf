process SALMON_INDEX_VIRAL {

    tag "salmon_index"
    publishDir "${params.outdir}/${project_name}/salmon_index", mode: 'copy'

    input:
    path viral_fasta
    val project_name

    output:
    path "salmon_index", emit: salmon_index

    script:
    """
    salmon index \
        -t ${viral_fasta} \
        -i salmon_index \
        -k 31
    """
}
