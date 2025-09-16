// ---------------------------------------------
// FASTQC: reads quality check
// ---------------------------------------------

/* process FASTQC {

    debug true // Allow to mantain temporary files for debugging
    tag "${sample_id}"

    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    tuple val(sample_id), val(project_name), val(virus_to_detect), path(reads_pair)

    output:
    tuple val(sample_id), val(project_name), val(virus_to_detect), path("${sample_id}_R*_fastqc.*"), emit: fastqc_results

    script:
    """
    echo "Running FASTQC on ${sample_id} with reads: ${reads_pair}"
    fastqc ${reads_pair} 
    """
} */

// ---------------------------------------------
// FASTQC: reads quality check
// ---------------------------------------------
process FASTQC {
    tag "${sample_id}"

    publishDir "${params.outdir}/${project_name}/fastqc", mode: 'copy'

    input:
    tuple val(sample_id), val(project_name), val(virus_to_detect), path(r1), path(r2)

    output:
    tuple val(sample_id), val(project_name), val(virus_to_detect), path("*.html"), emit: fastqc_html
    tuple val(sample_id), val(project_name), val(virus_to_detect), path("*.zip"), emit: fastqc_zip

    script:
    """
    fastqc -t ${task.cpus} ${r1} ${r2}
    """
}
