// ---------------------------------------------
// BWA-MEM2 alignment to virus genome
// ---------------------------------------------
process BWA_MEM2_VIRUS {

    tag "$sample_id"
    publishDir "${params.outdir}/${project_name}/bwa_virus", mode: 'copy'

    input:
    tuple val(sample_id), val(project_name), val(virus_to_detect), path(unmapped_r1), path(unmapped_r2)
    path viral_bwa_index_prefix

    output:
    tuple val(sample_id), val(project_name), val(virus_to_detect),
          path("${sample_id}.virus.bam"), emit: bwa_virus_results

    script:
    def sentieon = "/opt/sentieon-genomics-202308.03/bin/sentieon"

    """
    source /rawdata/.sentieon_login

    echo "Running BWA-MEM2 alignment for sample: ${sample_id} against virus genome"

    ${sentieon} bwa mem -t ${task.cpus} ${viral_bwa_index_prefix} ${unmapped_r1} ${unmapped_r2} | \
    samtools view -Sb - | samtools sort -o "${sample_id}.virus.bam"

    samtools index "${sample_id}.virus.bam"
    """
}
