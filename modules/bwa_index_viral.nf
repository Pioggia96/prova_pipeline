process BWA_INDEX_VIRAL {

    tag "viral_index"
    publishDir "${params.outdir}/${project_name}/bwa_index", mode: 'copy'

    input:
    path viral_fasta
    val project_name

    output:
    path "viral_genome.fa", emit: viral_bwa_index_prefix

    script:
    def sentieon = "/opt/sentieon-genomics-202308.03/bin/sentieon"

    """
    source /rawdata/.sentieon_login

    cp ${viral_fasta} viral_genome.fa
    ${sentieon} bwa index viral_genome.fa
    """
}
