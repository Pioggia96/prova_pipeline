process KRAKEN2 {

    tag "${sample_id}"
    publishDir "${params.outdir}/${project_name}/kraken2", mode: 'copy'
    errorStrategy 'ignore'   // continua anche se Kraken2 non produce file

    input:
    tuple val(sample_id), val(project_name), val(virus_to_detect), path(r1), path(r2)
    path kraken2_db

    output:
    tuple val(sample_id), val(project_name), val(virus_to_detect),
          path("${sample_id}.kraken2.out"),
          path("${sample_id}.kraken2.classified_1.fq.gz"),
          path("${sample_id}.kraken2.classified_2.fq.gz"),
          path("${sample_id}.kraken2.unclassified_1.fq.gz"),
          path("${sample_id}.kraken2.unclassified_2.fq.gz"),
          path("${sample_id}.kraken2.report"),
          emit: kraken_reports

    script:
    """
    kraken2 \\
        --db ${kraken2_db} \\
        --report ${sample_id}.kraken2.report \\
        --paired ${r1} ${r2} \\
        --output ${sample_id}.kraken2.out \\
        --threads ${task.cpus} \\
        --use-names \\
        --classified-out ${sample_id}.kraken2.classified_#.fq.gz \\
        --unclassified-out ${sample_id}.kraken2.unclassified_#.fq.gz
    """
}
