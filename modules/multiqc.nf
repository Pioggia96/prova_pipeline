// ---------------------------------------------
// MULTIQC: stats collection and repor
// ---------------------------------------------

process MULTIQC {

    tag "multiqc_report"
    publishDir "${params.outdir}/multiqc", mode: 'copy'

    input:
    path(all_input_files_for_multiqc)

    output:
    path "multiqc_report.html", emit: multiqc_report

    script:
    """
    multiqc --filename "multiqc_report.html" .
    """
}

